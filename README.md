# OpenCode Team Config v2

One-command setup for the team's shared OpenCode configuration: plugins, MCPs, agents, skills, and workflow.

## Architecture

Three-layer framework with oh-my-opencode-slim orchestration:

| Layer | Framework | Responsibility |
|-------|-----------|----------------|
| Decision | gstack (pure MD port) | Requirements validation, architecture review, security audit |
| Context | GSD (npx gsd-opencode --global) | Spec persistence, atomic task splitting, fresh context per task |
| Execution | Superpowers | TDD, worktrees, parallel agents, code review |
| Orchestration | oh-my-opencode-slim | Agent routing, 30+ hooks, session management |

## Agent Roles

| Agent | Role | Customization |
|-------|------|---------------|
| Orchestrator | Routes tasks, creates worktrees, coordinates pipeline | `agents/orchestrator_append.md` |
| Explorer | Codebase discovery and pattern mapping | slim default |
| Oracle → plan-reviewer | Reviews PLANS (not code). Max 2 cycles. | `agents/oracle.md` |
| Fixer → executor | TDD implementation (RED→GREEN→REFACTOR) | `agents/fixer.md` |
| code-reviewer | Reviews CODE (not plans). 8-dimension framework. | `agents/code-reviewer.md` |
| Librarian | Documentation research + requirement clarification | `agents/librarian_append.md` |
| Designer, Council, Observer | Preserved from slim defaults | unchanged |

## Workflow

```
User input
  → Orchestrator classifies + creates worktree
  → @Librarian: requirements clarification (/grill-me)
  → @Explorer: codebase scan
  → GSD /gsd-plan-phase → task_plan.md (numbered cards)
  → @plan-reviewer: reviews plan (max 2 cycles)
  → plannotator: user visual annotation
  → FOR EACH card:
      @executor: team-tdd (RED→GREEN→REFACTOR→COMMIT)
      @code-reviewer: validates (max 2 cycles)
  → squash to 1 commit (trunk-based)
```

## Plugins (8)

| Plugin | Purpose |
|--------|---------|
| `oh-my-opencode-slim` | Agent orchestration + 30+ hooks |
| `superpowers` | TDD, worktrees, parallel agents, code review skills |
| `@plannotator/opencode@0.19.3` | Interactive plan annotation UI |
| `opencode-ralph-loop` | Autonomous iteration loop |
| `cc-safety-net@0.6.0` | Destructive command interception |
| `opencode-agent-skills@0.6.4` | Dynamic skill discovery + loading |
| `@tarquinen/opencode-dcp` | Context pruning (compress/deduplicate/purge) |
| `opencode-working-memory` | Cross-session memory (zero API calls, compaction-based) |
| `context-mode` | MCP output compression (98% reduction) |

## MCP Servers (8)

| MCP | Type | Purpose |
|-----|------|---------|
| `context7` | remote | Up-to-date library documentation |
| `sequential-thinking` | local | Structured reasoning chains |
| `playwright` | local | Browser automation / E2E testing |
| `github` | local | GitHub API |
| `azure-devops` | local | Azure DevOps |
| `grep_app` | remote | GitHub code search |
| `exa` | remote | Web search |
| `postgres` | local | Database schema/queries (disabled by default) |

## Skills

### Team Skills (in this repo)

| Skill | Purpose |
|-------|---------|
| `team-tdd` | Comprehensive TDD (superpowers iron law + mattpocock vertical slicing + code constraints) |
| `frontend-tdd` | React TDD constraints (component size, query priority) |
| `git-master` | Advanced git workflows |
| `frontend-ui-ux` | Tailwind/CSS/design patterns |
| `playwright-cli` | E2E testing |
| `humanizer` | AI writing cleanup |

### Third-Party Skills (installed by setup.sh)

| Skill | Source | Stack |
|-------|--------|-------|
| mattpocock/skills | MIT | /diagnose, /grill-me, /tdd, /to-issues, /caveman, etc. |
| vercel-react-best-practices | Vercel official | React (70 rules) |
| next-best-practices | Vercel official | Next.js App Router |
| kotlin-agent-skills | JetBrains official | Kotlin backend |
| terraform-skill | Community | Terraform/OpenTofu |
| pg-aiguide | Timescale | PostgreSQL best practices |
| openspec | Community | Spec-driven development (manual install, see setup.sh) |

### AWS

awslabs/agent-plugins is **not compatible with OpenCode** (only Claude Code, Cursor, Codex, Kiro).
For AWS integration, use MCP servers (e.g., `@aws-devops/mcp`) instead.

## Quick Start

```bash
# 1. Clone
git clone <repo-url> ~/projects/opencode-team-config

# 2. Run setup
cd ~/projects/opencode-team-config
bash setup.sh

# 3. Add environment variables to ~/.zshrc
export AZURE_DEVOPS_ORG=your-org-name
export GITHUB_TOKEN=$(gh auth token)
export EXA_API_KEY=your-key              # optional
```

## Updating

```bash
cd ~/projects/opencode-team-config
bash update.sh   # git pull + setup.sh
```

## Project Setup

Copy `templates/AGENTS.md` to your project root and fill in project-specific details.

## Prerequisites

- **opencode** — `brew install opencode`
- **Node.js / npx** — `brew install node`
- **bun** — `brew install oven-sh/bun/bun` (for oh-my-opencode-slim)
- **AZURE_DEVOPS_ORG** environment variable
