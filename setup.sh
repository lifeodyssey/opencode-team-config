#!/usr/bin/env bash
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPENCODE_DIR="$HOME/.config/opencode"
SLIM_DIR="$HOME/.config/opencode/oh-my-opencode-slim"

echo "=== OpenCode Team Config v2 Setup ==="
echo ""

# ─── Prerequisites ───────────────────────────────────────────────
command -v opencode >/dev/null 2>&1 || {
  echo "Error: opencode not installed."
  echo "Install with: brew install opencode"
  exit 1
}

# Version check + upgrade
CURRENT_VERSION=$(opencode --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
echo "OpenCode version: ${CURRENT_VERSION:-unknown}"

echo "Checking for OpenCode updates..."
brew upgrade opencode 2>/dev/null && {
  NEW_VERSION=$(opencode --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
  echo "OpenCode upgraded: $CURRENT_VERSION → $NEW_VERSION"
} || echo "OpenCode is up to date."

command -v npx >/dev/null 2>&1 || {
  echo "Error: npx not found. Install Node.js: brew install node"
  exit 1
}

mkdir -p "$OPENCODE_DIR/skills" "$OPENCODE_DIR/plugins"

# ─── oh-my-opencode-slim ────────────────────────────────────────
echo ""
echo "--- Installing oh-my-opencode-slim ---"
if command -v bunx >/dev/null 2>&1; then
  bunx oh-my-opencode-slim@latest install --reset 2>/dev/null || echo "Warning: oh-my-opencode-slim install had issues. You may need to run: bunx oh-my-opencode-slim@latest install"
else
  echo "Warning: bunx not found. Install bun (brew install oven-sh/bun/bun) then run: bunx oh-my-opencode-slim@latest install"
fi

# ─── Copy slim config (models + presets) ────────────────────────
echo ""
echo "--- Configuring oh-my-opencode-slim ---"
if [ -f "$REPO_DIR/oh-my-opencode-slim.json" ]; then
  cp "$REPO_DIR/oh-my-opencode-slim.json" "$OPENCODE_DIR/oh-my-opencode-slim.json"
  echo "OK slim config: github-copilot preset"
fi

# ─── Copy agent prompt customizations for slim ──────────────────
mkdir -p "$SLIM_DIR"
for prompt_file in "$REPO_DIR/agents"/*.md; do
  prompt_name=$(basename "$prompt_file")
  cp "$prompt_file" "$SLIM_DIR/$prompt_name"
  echo "OK agent prompt: $prompt_name"
done

# ─── Install ast-grep CLI ───────────────────────────────────────
if ! command -v sg >/dev/null 2>&1; then
  echo "Installing ast-grep..."
  brew install ast-grep 2>/dev/null || npm install -g @ast-grep/cli 2>/dev/null || echo "Warning: ast-grep install failed"
else
  echo "OK tool: ast-grep"
fi

# ─── Copy custom skills ─────────────────────────────────────────
echo ""
echo "--- Installing custom skills ---"
for skill_dir in "$REPO_DIR/skills"/*/; do
  skill_name=$(basename "$skill_dir")
  rm -rf "$OPENCODE_DIR/skills/$skill_name"
  cp -r "$skill_dir" "$OPENCODE_DIR/skills/$skill_name"
  echo "OK skill: $skill_name"
done

# ─── Copy custom commands ────────────────────────────────────────
mkdir -p "$OPENCODE_DIR/command"
for cmd_file in "$REPO_DIR/commands"/*.md; do
  cmd_name=$(basename "$cmd_file")
  cp "$cmd_file" "$OPENCODE_DIR/command/$cmd_name"
  echo "OK command: ${cmd_name%.md}"
done

# ─── Install third-party skills via npx skills ──────────────────
echo ""
echo "--- Installing third-party skills ---"

install_skill() {
  local name="$1"
  shift
  echo -n "Installing skill: $name... "
  npx skills@latest add "$@" --yes --global 2>/dev/null && echo "OK" || echo "SKIP (may already exist)"
}

install_skill "mattpocock/skills" mattpocock/skills
install_skill "vercel-react-best-practices" vercel-labs/agent-skills --skill vercel-react-best-practices
install_skill "next-best-practices" vercel-labs/next-skills --skill next-best-practices
install_skill "kotlin-agent-skills" Kotlin/kotlin-agent-skills
install_skill "terraform-skill" "https://github.com/antonbabenko/terraform-skill"
install_skill "pg-aiguide" timescale/pg-aiguide
# openspec: not compatible with npx skills (no SKILL.md), install via git clone
if [ ! -d "$OPENCODE_DIR/skills/openspec" ]; then
  echo -n "Installing skill: openspec... "
  git clone --depth 1 https://github.com/fission-ai/openspec.git "$OPENCODE_DIR/skills/openspec" 2>/dev/null && echo "OK" || echo "SKIP"
else
  echo "OK skill: openspec (already installed)"
fi

# ─── AWS note ────────────────────────────────────────────────────
# awslabs/agent-plugins only supports Claude Code, Cursor, Codex, Kiro.
# NOT compatible with OpenCode. Use AWS MCP servers instead if needed.

# ─── Merge opencode.json ────────────────────────────────────────
echo ""
echo "--- Merging opencode.json ---"
python3 - "$REPO_DIR/opencode.json" "$OPENCODE_DIR/opencode.json" <<'PYEOF'
import json, sys, os

template = json.load(open(sys.argv[1]))
target_path = sys.argv[2]
target = json.load(open(target_path)) if os.path.exists(target_path) else {}

# Remove deprecated plugins
deprecated_plugins = ["oh-my-opencode", "claude-mem-opencode"]
existing_plugins = [p for p in target.get("plugin", []) if p not in deprecated_plugins]
for p in template.get("plugin", []):
    if p not in existing_plugins:
        existing_plugins.append(p)
target["plugin"] = existing_plugins

# Merge mcp (add missing only, never overwrite personal entries)
target_mcp = target.get("mcp", {})
# Remove deprecated MCPs
deprecated_mcps = ["astro-docs", "chrome-devtools", "serena"]
for dep in deprecated_mcps:
    target_mcp.pop(dep, None)
for k, v in template.get("mcp", {}).items():
    if k not in target_mcp:
        target_mcp[k] = v
target["mcp"] = target_mcp

# Remove old native agents (slim handles agent routing now)
target.pop("agent", None)

if "$schema" not in target:
    target["$schema"] = template["$schema"]

json.dump(target, open(target_path, "w"), indent=2, ensure_ascii=False)
print("OK opencode.json merged")
PYEOF

# ─── Cleanup deprecated skills from user config ─────────────────
echo ""
echo "--- Cleaning up deprecated configs ---"
deprecated_skills=("google-adk" "google-a2ui" "excalidraw-skill" "dev-browser" "backend-tdd" "python-dev")

# Remove old claude-mem plugin (replaced by opencode-working-memory)
if [ -f "$OPENCODE_DIR/plugins/claude-mem.js" ]; then
  rm -f "$OPENCODE_DIR/plugins/claude-mem.js"
  echo "Removed deprecated plugin: claude-mem.js (replaced by opencode-working-memory)"
fi
for skill in "${deprecated_skills[@]}"; do
  if [ -d "$OPENCODE_DIR/skills/$skill" ]; then
    rm -rf "$OPENCODE_DIR/skills/$skill"
    echo "Removed deprecated skill: $skill"
  fi
done

# ─── opencode-working-memory (replaces claude-mem) ───────────────
# Zero config, zero API calls — memory piggybacks on compaction.
# Installed via opencode.json plugin list, no setup needed.

echo ""
echo "=== Setup complete ==="
echo ""
echo "Required environment variables (add to ~/.zshrc):"
echo "  export AZURE_DEVOPS_ORG=your-org-name"
echo ""
echo "Optional environment variables:"
echo "  export EXA_API_KEY=your-key       # Exa web search (free: 1000 req/mo at exa.ai)"
echo "  export DATABASE_URL=postgres://... # For postgres MCP (disabled by default)"
echo ""
echo "First-time setup:"
echo "  opencode providers login            # Login to GitHub Copilot or other provider"
echo ""
echo "Verify installation:"
echo "  opencode mcp list                  # Should show 9 MCPs"
echo "  opencode debug skill               # Should show 8+ skills"
echo "  opencode agent list                # Should show slim agents (orchestrator, executor, etc.)"
echo ""
