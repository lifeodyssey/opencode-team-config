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

# Copy custom skills (cp, not symlink)
for skill_dir in "$REPO_DIR/skills"/*/; do
  skill_name=$(basename "$skill_dir")
  rm -rf "$OPENCODE_DIR/skills/$skill_name"
  cp -r "$skill_dir" "$OPENCODE_DIR/skills/$skill_name"
  echo "OK skill: $skill_name"
done

# Merge opencode.json (add missing entries only, preserve existing personal config)
python3 - "$REPO_DIR/opencode.json" "$OPENCODE_DIR/opencode.json" <<'PYEOF'
import json, sys, os

template = json.load(open(sys.argv[1]))
target_path = sys.argv[2]
target = json.load(open(target_path)) if os.path.exists(target_path) else {}

# Merge plugin array (deduplicate, preserve order)
existing_plugins = target.get("plugin", [])
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

# Always apply team agent model overrides (ensures correct GitHub Copilot model IDs)
if "agent" in template:
    target["agent"] = template["agent"]

if "$schema" not in target:
    target["$schema"] = template["$schema"]

json.dump(target, open(target_path, "w"), indent=2, ensure_ascii=False)
print("OK opencode.json merged")
PYEOF

# Copy oh-my-opencode agent config (always overwrite - team config controls thinking/fallback)
cp "$REPO_DIR/oh-my-opencode.json" "$OPENCODE_DIR/oh-my-opencode.json"
echo "OK oh-my-opencode.json copied"

# Clear GitHub Copilot model variants from opencode state
# Variants like "high"/"thinking" produce invalid model IDs (e.g. claude-sonnet-4-6-high)
# that GitHub Copilot does not recognise, causing ProviderModelNotFoundError
STATE_MODEL="$HOME/.local/state/opencode/model.json"
if [ -f "$STATE_MODEL" ]; then
  python3 - "$STATE_MODEL" <<'PYEOF'
import json, sys
path = sys.argv[1]
data = json.load(open(path))
if data.get("variant"):
    data["variant"] = {}
    json.dump(data, open(path, "w"), indent=2, ensure_ascii=False)
    print("OK cleared github-copilot model variants from state")
else:
    print("OK model variants already clean")
PYEOF
fi

echo ""
echo "=== Setup complete ==="
echo ""
echo "Required environment variable (add to ~/.zshrc):"
echo "  export AZURE_DEVOPS_ORG=your-org-name"
echo ""
echo "First-time MCP authentication:"
echo "  opencode mcp auth github      # GitHub OAuth"
echo "  Azure DevOps: browser login triggers automatically on first use"
echo ""
echo "npm plugins will auto-install on first opencode launch."
echo ""
echo "Verify installation:"
echo "  opencode mcp list"
echo "  opencode debug skill"
echo "  opencode agent list"
