---
description: (builtin) Start ultrawork mode - deploy all agents with maximum precision until task is complete
---

You are starting an ULTRAWORK session. All specialist agents are at your disposal.

Your mission: Complete the following task with maximum precision and thoroughness.

**Available agents (oh-my-opencode-slim):**
- @Orchestrator — route tasks, create worktrees, coordinate pipeline
- @Explorer — codebase discovery and pattern mapping
- @Oracle — plan review (PLANS only, not code)
- @Fixer — TDD implementation (team-tdd: RED→GREEN→REFACTOR)
- @code-reviewer — code review (CODE only, not plans)
- @Librarian — documentation research
- @Council — multi-model consensus for critical decisions

**Workflow: Orchestrator drives the pipeline automatically.**
1. Classify task → create worktree
2. @Librarian clarifies requirements (if unclear)
3. @Explorer scans codebase
4. GSD /gsd-plan-phase → task_plan.md with numbered cards
5. @Oracle reviews plan (max 2 cycles)
6. For each card: @Fixer implements (TDD) → @code-reviewer validates
7. Squash to 1 commit (trunk-based)

Track every card. Do NOT stop until all cards are ✅ and verified.

<user-task>
$ARGUMENTS
</user-task>
