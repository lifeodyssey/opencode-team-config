# OpenCode Team Config v2

One-command setup for the team's shared OpenCode configuration: plugins, MCPs, agents, skills, and workflow.

## Architecture

| Layer | Framework | Responsibility |
|-------|-----------|----------------|
| Decision | gstack (pure MD port) | Requirements validation, architecture review, security audit |
| Context | GSD (pre-installed via setup.sh) | Spec persistence, atomic task splitting, fresh context per task |
| Execution | Superpowers | TDD, worktrees, parallel agents, code review |
| Orchestration | oh-my-opencode-slim | Agent routing, 30+ hooks, session management |

## Agent Roles

| Agent | Model | Role | Config |
|-------|-------|------|--------|
| Orchestrator | claude-opus-4.6 | Routes tasks, creates worktrees, coordinates pipeline | `agents/orchestrator_append.md` |
| plan-reviewer | gpt-5.5 | Reviews PLANS (not code). Max 2 cycles. | custom agent in slim json |
| executor | gpt-5.5 | TDD implementation (RED→GREEN→REFACTOR) | custom agent in slim json |
| code-reviewer | claude-sonnet-4.6 | Reviews CODE (not plans). 8-dimension framework. | `agents/code-reviewer.md` |
| Explorer | gpt-5.4-mini | Codebase discovery and pattern mapping | slim default |
| Librarian | gpt-5.4-mini | Documentation research + requirement clarification | `agents/librarian_append.md` |
| Designer | gpt-5.4-mini | UI/UX design | slim default |
| Council | gpt-5.5 | Multi-model consensus for critical decisions | slim default |
| oracle | gpt-5.5 | Plan review (slim built-in, kept for routing compat) | slim default |
| fixer | gpt-5.4-mini | Implementation (slim built-in, kept for routing compat) | slim default |

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

Note: GSD is installed as skills/commands (not plugin) via `npx gsd-opencode --global` to avoid Bun crash.

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
| openspec | Community | Spec-driven development |

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

# 4. Login to provider
opencode providers login
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
