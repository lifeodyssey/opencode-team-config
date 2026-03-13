# OpenCode Team Config

One-command setup for the team's shared OpenCode configuration: plugins, MCPs, and custom skills.

## What's Included

### Plugins (npm, auto-installed on first launch)

| Plugin | Purpose |
|--------|---------|
| `@plannotator/opencode@latest` | Interactive plan annotation UI (`/plan`) |
| `oh-my-opencode` | Multi-agent workflows: code review (Oracle), feature dev (Hephaestus), git expert |
| `opencode-froggy` | Code reviewer, rubber-duck debugger, partner agent |
| `opencode-ralph-loop` | Iterative Ralph loop for repetitive refinement |
| `cc-safety-net` | Intercepts destructive commands before execution |
| `opencode-worktree` | Git worktree management for isolated feature branches |
| `opencode-agent-skills` | Dynamic skill loading for agents |
| `superpowers` | (local .js) Brainstorming, planning, TDD, and workflow skills |

### MCP Servers

| MCP | Type | Purpose |
|-----|------|---------|
| `context7` | remote | Up-to-date library documentation |
| `sequential-thinking` | local (npx) | Structured reasoning chains |
| `playwright` | local (npx) | Browser automation |
| `astro-docs` | remote | Astro framework documentation |
| `github` | local (npx) | GitHub API (GITHUB_TOKEN from gh CLI) — ⚠️ may have issues, skip if not needed |
| `azure-devops` | local (npx) | Azure DevOps (browser MSA login) — ⚠️ may have issues, skip if not needed |
| `chrome-devtools` | local (npx) | Chrome DevTools protocol |
| `serena` | local (uvx) | Semantic code navigation (LSP-like) |

### Custom Skills

| Skill | Triggers |
|-------|---------|
| `python-dev` | `python`, `pytest`, `uv sync`, `pyproject.toml`, `ruff` |
| `humanizer` | `humanize`, AI writing cleanup |
| `google-adk` | `adk`, `google adk`, `vertex ai agent` |
| `google-a2ui` | `a2ui`, `agent to ui`, `agent ui` |
| `excalidraw-skill` | `excalidraw`, diagram drawing via MCP canvas |

## Prerequisites

- **opencode** — `brew install opencode`
- **uv** — `brew install uv` (required for serena MCP)
- **git** — pre-installed on macOS
- **Node.js / npx** — `brew install node` (for local MCP servers)
- **AZURE_DEVOPS_ORG** environment variable — add to `~/.zshrc`:
  ```bash
  export AZURE_DEVOPS_ORG=your-org-name
  ```

## Quick Start

```bash
# 1. Clone this repo (any path works)
git clone <repo-url> ~/projects/opencode-team-config

# 2. Run setup (backs up existing config, installs everything)
cd ~/projects/opencode-team-config
bash setup.sh

# 3. Add environment variables to ~/.zshrc
export AZURE_DEVOPS_ORG=your-org-name
export GITHUB_TOKEN=$(gh auth token)    # reuses gh CLI session, no PAT needed
```

npm plugins auto-install on the first `opencode` launch. No manual `npm install` needed.

## Updating

```bash
cd ~/projects/opencode-team-config
git pull
bash setup.sh
```

`setup.sh` is idempotent — safe to re-run. It overwrites skills and updates superpowers, but **never overwrites existing MCP entries** you've added personally.

## Config Merge Strategy

`setup.sh` merges `opencode.json` into your existing `~/.config/opencode/opencode.json` using a Python inline script:

- **Plugins**: adds missing entries, preserves existing order
- **MCPs**: adds missing keys only, never overwrites your personal entries
- **Personal MCPs** (e.g. google-docs, greptile): untouched

## Manual Notes

### superpowers
No npm package — installed from source:
```bash
git clone https://github.com/obra/superpowers ~/.config/opencode/superpowers
cp ~/.config/opencode/superpowers/.opencode/plugins/superpowers.js ~/.config/opencode/plugins/
```
`setup.sh` handles this automatically. On re-run it does `git pull` to update.

### GitHub MCP ⚠️
May have connection issues depending on your Copilot plan / `gh` auth status. Uses local `@github/mcp-server` via npx with a GitHub token:
```bash
export GITHUB_TOKEN=$(gh auth token)   # add to ~/.zshrc
```
Reuses the existing `gh` CLI session. No PAT required. **Can be skipped** — set `"enabled": false` in `opencode.json` if not needed.

### Azure DevOps MCP ⚠️
May have connection issues depending on your org/tenant setup. Requires `AZURE_DEVOPS_ORG` in environment. Browser MSA login triggers on first use. **Can be skipped** — set `"enabled": false` in `opencode.json` if not needed.

### serena
Python-based MCP server. Requires `uv` / `uvx`:
```bash
brew install uv
```
Installed fresh from `git+https://github.com/oraios/serena` on each MCP server start (cached by uvx).

## Verification

After setup, verify with:

```bash
opencode mcp list           # Should show 8 MCPs
opencode debug skill        # Should show 5 skills under ~/.config/opencode/skills/
opencode agent list         # Should show agents from oh-my-opencode and opencode-froggy
opencode debug config       # Full config dump
```
