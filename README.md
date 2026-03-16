# OpenCode Team Config

One-command setup for the team's shared OpenCode configuration: plugins, MCPs, agents, skills, and commands.

## What's Included

### Plugins (npm, auto-installed on first launch)

| Plugin | Purpose |
|--------|---------|
| `@plannotator/opencode@latest` | Interactive plan annotation UI (`/plan`) |
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
| `grep_app` | remote | GitHub code search across public repos (no key needed) |
| `exa` | remote | Web search (free: 1000 req/mo with EXA_API_KEY) |

### Native Agents

| Agent | Model | Mode | Role |
|-------|-------|------|------|
| `sisyphus` | Opus 4.6 | all | Main orchestrator — plans, delegates, drives tasks to completion |
| `oracle` | Opus 4.6 | subagent | Read-only consultant for debugging & architecture (no code) |
| `metis` | Opus 4.6 | subagent | Pre-planning analyst — clarifies intent before planning |
| `atlas` | Opus 4.6 | all | Master orchestrator — works through a full todo list |
| `prometheus` | Opus 4.6 | primary | Strategic planner — interview mode, never implements |
| `hephaestus` | Sonnet 4.6 | all | Implementation specialist — writes and ships code |
| `momus` | Sonnet 4.6 | subagent | Plan reviewer — validates executability (max 3 blockers) |
| `explore` | Sonnet 4.6 | subagent | Codebase explorer — maps patterns before implementation |
| `multimodal-looker` | Sonnet 4.6 | subagent | Visual analyst — analyzes screenshots and images |
| `librarian` | Haiku 4.5 | subagent | Docs researcher — uses context7 and grep_app |

All agents use GitHub Copilot model routing (`github-copilot/*`).

### Custom Skills

| Skill | Source | Triggers |
|-------|--------|---------|
| `python-dev` | repo | `python`, `pytest`, `uv sync`, `pyproject.toml`, `ruff` |
| `humanizer` | repo | `humanize`, AI writing cleanup |
| `google-adk` | repo | `adk`, `google adk`, `vertex ai agent` |
| `google-a2ui` | repo | `a2ui`, `agent to ui`, `agent ui` |
| `excalidraw-skill` | repo | `excalidraw`, diagram drawing via MCP canvas |
| `git-master` | oh-my-opencode | `commit`, `rebase`, `squash`, `bisect`, `blame` |
| `frontend-ui-ux` | oh-my-opencode | `ui`, `ux`, `css`, `tailwind`, `component`, `design` |
| `dev-browser` | oh-my-opencode | `go to`, `scrape`, `automate browser`, `navigate` |
| `playwright-cli` | oh-my-opencode | `playwright`, `e2e`, `browser test` |
| `prd` | ralph | `prd`, `product requirements` |
| `ralph` | ralph | `ralph`, `autonomous loop` |

### Commands

| Command | Description |
|---------|-------------|
| `/init-deep` | Generate hierarchical AGENTS.md across project directories |
| `/start-work [plan]` | Start Sisyphus work session from a Prometheus plan |
| `/stop-continuation` | Stop all continuation mechanisms (ralph loop, todo continuation) |
| `/handoff` | Create context summary for continuing work in a new session |
| `/refactor <target>` | Intelligent refactoring with `--scope` and `--strategy` options |
| `/ultrawork <task>` | Deploy all agents with maximum precision until task is complete |
| `/ulw-loop <task>` | ULTRAWORK loop — runs until Oracle verifies completion (no limit) |
| `/ralph-loop` | Iterative loop via `opencode-ralph-loop` plugin |
| `/cancel-ralph` | Cancel active Ralph loop |

### Tools

| Tool | Install | Purpose |
|------|---------|---------|
| `ast-grep` (`sg`) | `brew install ast-grep` | Structural code search across 25 languages |
| `ralph.sh` | auto (git clone) | Autonomous PRD-based development loop |

## Prerequisites

- **opencode** — `brew install opencode`
- **uv** — `brew install uv` (required for serena MCP)
- **git** — pre-installed on macOS
- **Node.js / npx** — `brew install node` (for local MCP servers)
- **AZURE_DEVOPS_ORG** environment variable — add to `~/.zshrc`:
  ```bash
  export AZURE_DEVOPS_ORG=your-org-name
  ```
- **EXA_API_KEY** (optional) — add to `~/.zshrc` for Exa web search:
  ```bash
  export EXA_API_KEY=your-key   # Get free key at exa.ai (1000 req/mo free)
  ```

## Quick Start

```bash
# 1. Clone this repo (any path works)
git clone <repo-url> ~/projects/opencode-team-config

# 2. Run setup (installs everything)
cd ~/projects/opencode-team-config
bash setup.sh

# 3. Add environment variables to ~/.zshrc
export AZURE_DEVOPS_ORG=your-org-name
export GITHUB_TOKEN=$(gh auth token)    # reuses gh CLI session, no PAT needed
export EXA_API_KEY=your-key             # optional, for enhanced web search
```

npm plugins auto-install on the first `opencode` launch. No manual `npm install` needed.

## Updating

```bash
cd ~/projects/opencode-team-config
git pull
bash setup.sh
```

`setup.sh` is idempotent — safe to re-run. It overwrites skills and updates superpowers/ralph, but **never overwrites existing MCP entries** you've added personally.

## Config Merge Strategy

`setup.sh` merges `opencode.json` into your existing `~/.config/opencode/opencode.json`:

- **Plugins**: adds missing entries, removes oh-my-opencode if present, preserves existing order
- **MCPs**: adds missing keys only, never overwrites your personal entries
- **Agents**: always applies team overrides (ensures correct models and prompts)
- **Personal MCPs** (e.g. google-docs, greptile): untouched

## Manual Notes

### superpowers
No npm package — installed from source:
```bash
git clone https://github.com/obra/superpowers ~/.config/opencode/superpowers
cp ~/.config/opencode/superpowers/.opencode/plugins/superpowers.js ~/.config/opencode/plugins/
```
`setup.sh` handles this automatically. On re-run it does `git pull` to update.

### ralph (autonomous PRD loop)
No npm package — installed from source:
```bash
git clone https://github.com/snarktank/ralph ~/.config/opencode/ralph
```
Skills from `ralph/skills/` are copied to `~/.config/opencode/skills/`. The main script `ralph.sh` stays at `~/.config/opencode/ralph/ralph.sh` and is run from your project directory.

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
opencode mcp list           # Should show 10 MCPs
opencode debug skill        # Should show 11+ skills
opencode agent list         # Should show 10 native agents
opencode debug config       # Full config dump
sg --version                # ast-grep CLI
ls ~/.config/opencode/command/  # Custom commands
```
