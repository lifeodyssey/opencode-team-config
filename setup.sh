#!/usr/bin/env bash
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPENCODE_DIR="$HOME/.config/opencode"

echo "=== OpenCode Team Config Setup ==="
echo ""

# Check prerequisites
command -v opencode >/dev/null 2>&1 || {
  echo "Error: opencode not installed."
  echo "Install with: brew install opencode"
  exit 1
}

command -v uvx >/dev/null 2>&1 || {
  echo "Warning: uvx not found. serena MCP will not work."
  echo "Install with: brew install uv"
}

mkdir -p "$OPENCODE_DIR/skills" "$OPENCODE_DIR/plugins"

# Install superpowers (git clone + cp, no symlink)
SUPERPOWERS_DIR="$OPENCODE_DIR/superpowers"
if [ -d "$SUPERPOWERS_DIR/.git" ]; then
  echo "Updating superpowers..."
  git -C "$SUPERPOWERS_DIR" pull --quiet
else
  echo "Installing superpowers..."
  git clone --quiet https://github.com/obra/superpowers "$SUPERPOWERS_DIR"
fi
cp "$SUPERPOWERS_DIR/.opencode/plugins/superpowers.js" "$OPENCODE_DIR/plugins/superpowers.js"
echo "OK plugin: superpowers"

# Install snarktank/ralph (git clone + copy skills, like superpowers)
RALPH_DIR="$OPENCODE_DIR/ralph"
if [ -d "$RALPH_DIR/.git" ]; then
  echo "Updating ralph..."
  git -C "$RALPH_DIR" pull --quiet
else
  echo "Installing ralph..."
  git clone --quiet https://github.com/snarktank/ralph "$RALPH_DIR"
fi
for skill_dir in "$RALPH_DIR/skills"/*/; do
  skill_name=$(basename "$skill_dir")
  rm -rf "$OPENCODE_DIR/skills/$skill_name"
  cp -r "$skill_dir" "$OPENCODE_DIR/skills/$skill_name"
  echo "OK skill: ralph/$skill_name"
done
echo "OK tool: ralph (run: ~/.config/opencode/ralph/ralph.sh)"

# Install ast-grep CLI (used by agents for structural code search)
if ! command -v sg >/dev/null 2>&1; then
  echo "Installing ast-grep..."
  brew install ast-grep 2>/dev/null || npm install -g @ast-grep/cli 2>/dev/null || echo "Warning: ast-grep install failed — install manually: brew install ast-grep"
else
  echo "OK tool: ast-grep"
fi

# Copy custom skills (cp, not symlink)
for skill_dir in "$REPO_DIR/skills"/*/; do
  skill_name=$(basename "$skill_dir")
  rm -rf "$OPENCODE_DIR/skills/$skill_name"
  cp -r "$skill_dir" "$OPENCODE_DIR/skills/$skill_name"
  echo "OK skill: $skill_name"
done

# Copy custom commands (cp, not symlink)
mkdir -p "$OPENCODE_DIR/command"
for cmd_file in "$REPO_DIR/commands"/*.md; do
  cmd_name=$(basename "$cmd_file")
  cp "$cmd_file" "$OPENCODE_DIR/command/$cmd_name"
  echo "OK command: ${cmd_name%.md}"
done

# Merge opencode.json (add missing entries only, preserve existing personal config)
python3 - "$REPO_DIR/opencode.json" "$OPENCODE_DIR/opencode.json" <<'PYEOF'
import json, sys, os

template = json.load(open(sys.argv[1]))
target_path = sys.argv[2]
target = json.load(open(target_path)) if os.path.exists(target_path) else {}

# Remove oh-my-opencode from plugin list if still present
existing_plugins = [p for p in target.get("plugin", []) if p != "oh-my-opencode"]
for p in template.get("plugin", []):
    if p not in existing_plugins:
        existing_plugins.append(p)
target["plugin"] = existing_plugins

# Merge mcp (add missing only, never overwrite personal entries)
target_mcp = target.get("mcp", {})
for k, v in template.get("mcp", {}).items():
    if k not in target_mcp:
        target_mcp[k] = v
target["mcp"] = target_mcp

# Always apply team agent overrides (ensures correct models and prompts)
if "agent" in template:
    target["agent"] = template["agent"]

if "$schema" not in target:
    target["$schema"] = template["$schema"]

json.dump(target, open(target_path, "w"), indent=2, ensure_ascii=False)
print("OK opencode.json merged")
PYEOF

echo ""
echo "=== Setup complete ==="
echo ""
echo "Required environment variable (add to ~/.zshrc):"
echo "  export AZURE_DEVOPS_ORG=your-org-name"
echo ""
echo "Optional environment variables:"
echo "  export EXA_API_KEY=your-key   # Exa web search (free: 1000 req/mo at exa.ai)"
echo ""
echo "First-time MCP authentication:"
echo "  opencode mcp auth github      # GitHub OAuth"
echo "  Azure DevOps: browser login triggers automatically on first use"
echo ""
echo "npm plugins will auto-install on first opencode launch."
echo ""
echo "Verify installation:"
echo "  opencode mcp list             # Should show 10 MCPs"
echo "  opencode debug skill          # Should show 11+ skills"
echo "  opencode agent list           # Should show 10 native agents"
echo ""
echo "Ralph autonomous loop (project-level):"
echo "  ~/.config/opencode/ralph/ralph.sh [max_iterations]"
