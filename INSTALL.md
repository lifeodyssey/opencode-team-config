# OpenCode Team Config — Agent Installation Guide

This guide is written for AI agents executing the install end-to-end. Each step includes the exact command, expected output, and a verification checkpoint before proceeding.

---

## Prerequisites Checklist

Run each check. All must pass before proceeding to Step 1.

```bash
which opencode
```
Expected: a path like `/opt/homebrew/bin/opencode`. If missing: `brew install opencode`

```bash
which uvx
```
Expected: a path like `/opt/homebrew/bin/uvx`. If missing: `brew install uv`

```bash
which git
```
Expected: `/usr/bin/git` or similar. If missing: install Xcode command line tools.

```bash
echo $AZURE_DEVOPS_ORG
```
Expected: your org name (non-empty string). If empty: add `export AZURE_DEVOPS_ORG=your-org-name` to `~/.zshrc` and `source ~/.zshrc`.

```bash
echo $GITHUB_TOKEN
```
Expected: a GitHub token string. If empty: run `gh auth login` first, then add `export GITHUB_TOKEN=$(gh auth token)` to `~/.zshrc` and `source ~/.zshrc`.

---

## Step 1: Backup Existing Config

```bash
cp -r ~/.config/opencode ~/.config/opencode.bak.$(date +%Y%m%d) 2>/dev/null || true
```

Expected: no output (directory may or may not exist). The `|| true` prevents failure if `~/.config/opencode` doesn't exist yet.

Checkpoint: `ls ~/.config/ | grep opencode` should show both `opencode` and `opencode.bak.*` if a previous config existed.

---

## Step 2: Run Setup Script

From the repo root:

```bash
cd ~/projects/opencode-team-config
bash setup.sh
```

Expected output (in order):
```
=== OpenCode Team Config Setup ===

Installing superpowers...          (or "Updating superpowers..." on re-run)
OK plugin: superpowers
OK skill: excalidraw-skill
OK skill: google-a2ui
OK skill: google-adk
OK skill: humanizer
OK skill: python-dev
OK opencode.json merged

=== Setup complete ===

Required environment variable (add to ~/.zshrc):
  export AZURE_DEVOPS_ORG=your-org-name

First-time MCP authentication:
  opencode mcp auth github      # GitHub OAuth
  Azure DevOps: browser login triggers automatically on first use

npm plugins will auto-install on first opencode launch.

Verify installation:
  opencode mcp list
  opencode debug skill
  opencode agent list
```

If any line shows an error (not starting with "OK"), stop and diagnose before continuing.

---

## Step 3: Verify File Structure

```bash
ls ~/.config/opencode/
```
Expected: `opencode.json  plugins/  skills/  superpowers/`

```bash
ls ~/.config/opencode/skills/
```
Expected: `excalidraw-skill  google-a2ui  google-adk  humanizer  python-dev`

```bash
ls ~/.config/opencode/plugins/
```
Expected: `superpowers.js`

```bash
cat ~/.config/opencode/plugins/superpowers.js | head -3
```
Expected: JavaScript content (not a symlink, not empty). First lines should look like JS code.

---

## Step 4: Verify opencode.json

```bash
cat ~/.config/opencode/opencode.json
```

Expected: JSON containing:
- `"plugin"` array with at least: `@plannotator/opencode@latest`, `oh-my-opencode`, `opencode-froggy`, `opencode-ralph-loop`, `cc-safety-net`, `opencode-worktree`, `opencode-agent-skills`
- `"mcp"` object with keys: `context7`, `sequential-thinking`, `playwright`, `astro-docs`, `github`, `azure-devops`, `chrome-devtools`, `serena`

---

## Step 5: Verify Skills via CLI

```bash
opencode debug skill
```

Expected: lists 5 skills, each with a path under `~/.config/opencode/skills/`:
- `python-dev` at `~/.config/opencode/skills/python-dev/SKILL.md`
- `humanizer` at `~/.config/opencode/skills/humanizer/SKILL.md`
- `google-adk` at `~/.config/opencode/skills/google-adk/SKILL.md`
- `google-a2ui` at `~/.config/opencode/skills/google-a2ui/SKILL.md`
- `excalidraw-skill` at `~/.config/opencode/skills/excalidraw-skill/SKILL.md`

Verify each path is a real file (not a symlink):
```bash
file ~/.config/opencode/skills/python-dev/SKILL.md
```
Expected: `ASCII text` or similar. Not `symbolic link`.

---

## Step 6: First-time MCP Authentication

### GitHub
No command needed. The GitHub MCP uses `GITHUB_TOKEN` from your environment (set in prerequisites). Azure DevOps browser MSA login triggers automatically on first use of an Azure DevOps tool.

---

## Step 7: Launch opencode (npm Plugin Auto-install)

```bash
opencode
```

On first launch, opencode downloads and installs all npm plugins from the `plugin` array. This may take 30-60 seconds depending on network speed.

Expected: no errors in the plugin loading phase. After launch, type `/quit` or press Ctrl+C to exit.

---

## Step 8: Verify Agents

```bash
opencode agent list
```

Expected: lists agents including:
- Agents from `oh-my-opencode` (e.g. Oracle, Hephaestus, Git expert)
- Agents from `opencode-froggy` (e.g. code-reviewer, rubber-duck)

If no agents are listed, the npm plugins may not have installed yet. Re-run `opencode` to trigger install, wait for completion, then re-check.

---

## Step 9: Verify MCPs

```bash
opencode mcp list
```

Expected: lists 8 MCPs with their status. All should show as configured (connected status depends on runtime).

---

## Step 10: Idempotency Check (Optional)

Re-running setup should succeed with no errors:

```bash
bash ~/projects/opencode-team-config/setup.sh
```

Expected: same output as Step 2, with "Updating superpowers..." instead of "Installing superpowers...". Skills are overwritten (expected). No errors.

---

## Skill Trigger Verification (Manual — requires opencode TUI)

Open opencode in a project directory and type each prompt to verify skill injection:

| Skill | Test prompt | Expected behavior |
|-------|-------------|-------------------|
| `python-dev` | `Set up a new python project with uv` | Skill injected, gives uv init/add instructions |
| `humanizer` | `Humanize: The implementation leverages cutting-edge methodologies` | Detects AI patterns, rewrites naturally |
| `google-adk` | `Create a Google ADK sequential agent` | Provides ADK SequentialAgent code template |
| `google-a2ui` | `Build an A2UI presenter for my agent` | Provides A2UI presenter pattern |
| `excalidraw-skill` | `Draw a system architecture diagram with Excalidraw` | Provides Excalidraw MCP operation steps |

---

## Troubleshooting

### `opencode debug skill` shows no skills
- Check `~/.config/opencode/skills/` exists and contains subdirectories with `SKILL.md` files
- Re-run `bash setup.sh`

### `opencode agent list` shows no agents
- npm plugins haven't installed yet — launch `opencode`, wait 30-60 seconds, exit, then retry
- Check `opencode debug config` to confirm plugins are listed

### serena MCP fails to connect
- Verify `uvx` is installed: `which uvx`
- Test manually: `uvx --from git+https://github.com/oraios/serena serena --help`
- Check that `PYTHONUNBUFFERED=1` is in the environment config in `opencode.json`

### GitHub MCP fails to connect
- Verify `GITHUB_TOKEN` is set: `echo $GITHUB_TOKEN`
- If empty: run `gh auth login`, then `export GITHUB_TOKEN=$(gh auth token)` in `~/.zshrc`
- Check that the `github` MCP entry uses `type: "local"` with `@github/mcp-server`

### Azure DevOps MCP not triggering login
- Verify `AZURE_DEVOPS_ORG` is set: `echo $AZURE_DEVOPS_ORG`
- The browser login only triggers when you actually use an Azure DevOps tool in a session
