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
Installing ralph...                (or "Updating ralph..." on re-run)
OK skill: ralph/prd
OK skill: ralph/ralph
OK tool: ralph (run: ~/.config/opencode/ralph/ralph.sh)
OK tool: ast-grep
OK skill: dev-browser
OK skill: excalidraw-skill
OK skill: frontend-ui-ux
OK skill: git-master
OK skill: google-a2ui
OK skill: google-adk
OK skill: humanizer
OK skill: playwright-cli
OK skill: python-dev
OK command: handoff
OK command: init-deep
OK command: refactor
OK command: start-work
OK command: stop-continuation
OK command: ultrawork
OK command: ulw-loop
OK opencode.json merged

=== Setup complete ===
```

If any line shows an error (not starting with "OK"), stop and diagnose before continuing.

---

## Step 3: Verify File Structure

```bash
ls ~/.config/opencode/
```
Expected: `opencode.json  plugins/  skills/  superpowers/  ralph/  command/`

```bash
ls ~/.config/opencode/skills/
```
Expected includes: `dev-browser  excalidraw-skill  frontend-ui-ux  git-master  google-a2ui  google-adk  humanizer  playwright-cli  python-dev  prd  ralph`

```bash
ls ~/.config/opencode/command/
```
Expected includes: `handoff.md  init-deep.md  refactor.md  start-work.md  stop-continuation.md  ultrawork.md  ulw-loop.md`

```bash
ls ~/.config/opencode/plugins/
```
Expected: `superpowers.js`

---

## Step 4: Verify opencode.json

```bash
cat ~/.config/opencode/opencode.json
```

Expected: JSON containing:
- `"plugin"` array with: `@plannotator/opencode@latest`, `opencode-froggy`, `opencode-ralph-loop`, `cc-safety-net`, `opencode-worktree`, `opencode-agent-skills` (NO `oh-my-opencode`)
- `"mcp"` object with 10 keys: `context7`, `sequential-thinking`, `playwright`, `astro-docs`, `github`, `azure-devops`, `chrome-devtools`, `serena`, `grep_app`, `exa`
- `"agent"` object with 10 agents each having `model`, `mode`, `description`, `prompt`, `color`

---

## Step 5: Verify Skills via CLI

```bash
opencode debug skill
```

Expected: lists 11+ skills under `~/.config/opencode/skills/`:
- `python-dev`, `humanizer`, `google-adk`, `google-a2ui`, `excalidraw-skill` (repo)
- `git-master`, `frontend-ui-ux`, `dev-browser`, `playwright-cli` (oh-my-opencode)
- `prd`, `ralph` (ralph)

Verify each path is a real file (not a symlink):
```bash
file ~/.config/opencode/skills/git-master/SKILL.md
```
Expected: `ASCII text` or similar. Not `symbolic link`.

---

## Step 6: First-time MCP Authentication

### GitHub
No command needed. The GitHub MCP uses `GITHUB_TOKEN` from your environment (set in prerequisites).

### Azure DevOps
Browser MSA login triggers automatically on first use of an Azure DevOps tool.

### Exa (optional)
Add `EXA_API_KEY` to `~/.zshrc` for 1000 free requests/month. Get key at exa.ai. Without a key, the free public endpoint still works with limited quota.

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

Expected: lists 10 native agents: sisyphus, oracle, metis, atlas, prometheus, hephaestus, momus, explore, multimodal-looker, librarian. Plus agents from `opencode-froggy`.

If no agents are listed, the npm plugins may not have installed yet. Re-run `opencode`, wait for completion, then re-check.

---

## Step 9: Verify MCPs

```bash
opencode mcp list
```

Expected: lists 10 MCPs. All should show as configured (connected status depends on runtime).

---

## Step 10: Idempotency Check (Optional)

Re-running setup should succeed with no errors:

```bash
bash ~/projects/opencode-team-config/setup.sh
```

Expected: same output as Step 2, with "Updating superpowers..." and "Updating ralph..." on re-run. Skills/commands are overwritten (expected). No errors.

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
| `git-master` | `Squash the last 3 commits` | Provides git rebase interactive instructions |
| `frontend-ui-ux` | `Design a card component with Tailwind` | Provides design-focused component guidance |

---

## Troubleshooting

### `opencode debug skill` shows no skills
- Check `~/.config/opencode/skills/` exists and contains subdirectories with `SKILL.md` files
- Re-run `bash setup.sh`

### `opencode agent list` shows no agents
- npm plugins haven't installed yet — launch `opencode`, wait 30-60 seconds, exit, then retry
- Check `opencode debug config` to confirm plugins are listed
- Native agents (sisyphus, oracle, etc.) should appear without plugins

### serena MCP fails to connect
- Verify `uvx` is installed: `which uvx`
- Test manually: `uvx --from git+https://github.com/oraios/serena serena --help`

### GitHub MCP fails to connect
- Verify `GITHUB_TOKEN` is set: `echo $GITHUB_TOKEN`
- If empty: run `gh auth login`, then `export GITHUB_TOKEN=$(gh auth token)` in `~/.zshrc`

### Azure DevOps MCP not triggering login
- Verify `AZURE_DEVOPS_ORG` is set: `echo $AZURE_DEVOPS_ORG`
- The browser login only triggers when you actually use an Azure DevOps tool in a session

### ast-grep not found after setup
- Install manually: `brew install ast-grep`
- Or: `npm install -g @ast-grep/cli`
- Verify: `sg --version`
