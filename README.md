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
| Orchestrator | claude-sonnet-4.6 | Routes tasks, creates worktrees, coordinates pipeline | `agents/orchestrator_append.md` |
| plan-reviewer | claude-sonnet-4.6 | Reviews PLANS (not code). Max 2 cycles. | custom agent in slim json |
| executor | gpt-5.3-codex | TDD implementation (RED→GREEN→REFACTOR) | custom agent in slim json |
| code-reviewer | gpt-5.4 | Reviews CODE (not plans). 8-dimension framework. | `agents/code-reviewer.md` |
| Explorer | gpt-5.4-mini | Codebase discovery and pattern mapping | slim default |
| Librarian | gpt-5.4-mini | Documentation research + requirement clarification | `agents/librarian_append.md` |
| Designer | gpt-5.4-mini | UI/UX design | slim default |
| Council | claude-sonnet-4.6 | Multi-model consensus for critical decisions | slim default |
| oracle | claude-sonnet-4.6 | Plan review (slim built-in, aliased to plan-reviewer) | slim default |
| fixer | gpt-5.3-codex | Implementation (slim built-in, aliased to executor) | slim default |

## Workflow

### Task Identification
Every code-change task starts by asking for a card/work item number (AB#1234). The card number is used to name worktrees, branches, plan files, spec files, and commit messages.

### Pipeline Routing (lite/full)

**Global rules** (TDD, git safety, file boundaries) apply to ALL tasks regardless of pipeline.

```
Lite Pipeline (simple tasks: single-file bugfix, ≤2 files):
  → @executor: TDD (RED→GREEN→REFACTOR→COMMIT)
  → @code-reviewer: validates (max 2 cycles)

Full Pipeline (complex tasks: multi-file feature, unclear requirements):
  → Orchestrator classifies + creates worktree (feat/AB1234-<name>)
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

## Plugins (9)

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

## Safety Net Rules

Team-enforced rules via `cc-safety-net` (installed to `~/.cc-safety-net/config.json`):

| Rule | Blocked Command | Reason |
|------|----------------|--------|
| no-skip-commit-hooks | `git commit --no-verify` | Bypasses pre-commit checks |
| no-skip-commit-hooks-short | `git commit -n` | Short form of --no-verify |
| no-skip-push-hooks | `git push --no-verify` | Bypasses pre-push checks |
| no-skip-merge-hooks | `git merge --no-verify` | Bypasses pre-merge checks |
| no-skip-rebase-hooks | `git rebase --no-verify` | Bypasses rebase hooks |

These are additive to cc-safety-net's built-in protections (force push, reset --hard, rm -rf, etc.).

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
