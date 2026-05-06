---
description: (builtin) Start work session from a plan
agent: Orchestrator
---

You are starting a work session.

## ARGUMENTS

- `/start-work [plan-name] [--worktree <path>]`
  - `plan-name` (optional): name or partial match of the plan to start
  - `--worktree <path>` (optional): absolute path to an existing git worktree to work in

## WHAT TO DO

1. **Find available plans**: Search for plan files at `.sisyphus/plans/` or `task_plan.md`

2. **Check for active state**: Read `.sisyphus/boulder.json` if it exists

3. **Decision logic**:
   - If `.sisyphus/boulder.json` exists AND plan has unchecked cards:
     - **APPEND** current session to session_ids
     - Continue work from last unchecked card
   - If no active plan OR all cards complete:
     - List available plan files
     - If ONE plan: auto-select it
     - If MULTIPLE plans: show list with timestamps, ask user to select

4. **Worktree Setup** (when `worktree_path` not already set in boulder.json):
   1. `git worktree list --porcelain` — see available worktrees
   2. Create: `git worktree add <absolute-path> <branch-or-HEAD>`
   3. Update boulder.json to add `"worktree_path": "<absolute-path>"`
   4. All work happens inside that worktree directory

5. **Create/Update boulder.json**:
   ```json
   {
     "active_plan": "/absolute/path/to/task_plan.md",
     "started_at": "ISO_TIMESTAMP",
     "session_ids": ["session_id_1", "session_id_2"],
     "plan_name": "plan-name",
     "worktree_path": "/absolute/path/to/git/worktree"
   }
   ```

6. **Read the plan file** and start executing cards using the Orchestrator workflow:
   - For each unchecked card: @Fixer (TDD) → @code-reviewer (validate)
   - Mark ✅ as each card completes
   - Track progress in progress.md

## CRITICAL

- The session_id is injected by the hook - use it directly
- Always update boulder.json BEFORE starting work
- Always set worktree_path in boulder.json before executing any cards
- Read the FULL plan file before delegating any cards
- Follow Orchestrator pipeline (Phase 5: EXECUTE)
- Trunk-based: squash all commits to 1 before completion
