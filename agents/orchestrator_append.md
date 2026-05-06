## ADDITIONAL WORKFLOW RULES

### Task Classification
Classify every task: feature | bugfix | refactor | infra | research

### Worktree (plugin: opencode-worktree)
Always create isolated worktree: `git worktree add .worktrees/feat-<name> -b feat/<name>`

### Task Tracking (Card System)
Track every task as a numbered card. Use checkbox format in task_plan.md:
- [ ] Card #1: <description>
- [ ] Card #2: <description>
Mark ✅ as each card completes. Never skip a card. Resume from last unchecked card.

Maintain state in `.sisyphus/boulder.json`:
```json
{
  "active_plan": "/path/to/task_plan.md",
  "started_at": "ISO_TIMESTAMP",
  "session_ids": ["session_id_1"],
  "worktree_path": "/path/to/worktree"
}
```
On session resume: read boulder.json, find last unchecked card, continue from there.

### Context Management (auto-triggered, no manual action needed)
These plugins handle context automatically — do NOT duplicate their work:
- **opencode-dcp** (plugin): auto-compresses/deduplicates conversation before sending to LLM
- **claude-mem-opencode** (plugin): auto-captures session → auto-injects relevant memories next session
- **context-mode** (MCP): auto-compresses MCP tool outputs (315KB→5.4KB)
- **oh-my-opencode-slim hooks**: context-window-monitor, preemptive-compaction, session-recovery
- **opencode-agent-skills** (plugin): auto-re-injects skill list after context compaction
- **superpowers** (plugin): auto-injects skill awareness at session start

### Workflow Pipeline

**Phase 1: REQUIREMENTS (if unclear)**
Delegate to @Librarian:
- Use /grill-me (mattpocock/skills) to ask forcing questions about intent
- Use /grill-with-docs (mattpocock/skills) if project has existing docs (CONTEXT.md, AGENTS.md)
- Use context7 MCP to look up library APIs relevant to the task
- Output: clear scoped requirements with acceptance criteria

**Phase 2: EXPLORE**
Delegate to @Explorer:
- Scan codebase for existing patterns, utilities, abstractions
- Use ast-grep (sg) for structural search
- Output: findings report (relevant files, reusable code, conventions)

**Phase 3: PLAN**
Use GSD /gsd-plan-phase (plugin: gsd-opencode):
- Input: requirements + Explorer findings
- Output: task_plan.md using planning-with-files format:
  - Numbered cards: `- [ ] Card #N: <description>`
  - Dependency graph (mark [P] for parallel, [S] for serial)
  - Test design per card (what test, what assertion)
  - Tech-stack annotation per card (which skill to apply)
  - read_files + write_files boundary per card (guardrail B3)
- Persist to task_plan.md + findings.md + progress.md (planning-with-files skill)

**Phase 4: PLAN REVIEW**
Delegate to @Oracle (plan-reviewer):
- Send task_plan.md for review
- Max 2 cycles, convergence = same issue twice → stop
- After plan-reviewer says LGTM → use plannotator (@plannotator/opencode plugin) to let USER annotate/approve the plan visually
- User may add/delete/modify cards via plannotator UI

**Phase 5: EXECUTE**
For each card in dependency order:
- IF [P] cards exist → use /dispatching-parallel-agents (superpowers)
- For multi-card waves → use /gsd-execute-phase (GSD, fresh 200K context per card)
- Delegate to @Fixer (executor) with:
  - Card spec from task_plan.md
  - Tech-stack skill annotation (e.g. "apply nextjs-react + frontend-tdd constraints")
  - Allowed files (read_files + write_files from card, guardrail B3)
- After @Fixer commits → delegate to @code-reviewer
- Max 2 review cycles per card
- On completion: mark card ✅ in task_plan.md, update progress.md

**Phase 6: SHIP**
- `git rebase -i` → squash all commits into ONE (trunk-based, single commit per branch)
- Update progress.md (planning-with-files)
- Do NOT create PR automatically. Notify user that all cards are complete.

### Loop Selection (tell @Fixer which to use)
- Single feature card → team-tdd loop (superpowers /test-driven-development)
- Quick bugfix → /gsd-quick (GSD plugin, skip planning)
- Multi-card wave → /gsd-execute-phase (GSD, fresh context per card) + team-tdd per card
- Iterative refinement → /ralph-loop (opencode-ralph-loop plugin)

### Parallel Decision
[P] cards: modify different files/modules AND no data dependency → parallel
[S] cards: task B reads/uses output of task A → serial
Use /dispatching-parallel-agents (superpowers) for [P] dispatch.

### Tech Stack Detection (annotate for @Fixer)
- .tsx/.ts → use skills: vercel-react-best-practices + next-best-practices (Vercel) + frontend-tdd
- .kt/.kts → use skills: kotlin-agent-skills (JetBrains official) + dr-jskill (Spring Boot)
- .tf/.hcl → use skills: terraform-skill (antonbabenko)
- .py → use skills: backend-tdd + python-dev
- .sql → use skills: pg-aiguide (Timescale) via MCP
- AWS resources → use: awslabs agent-plugins (deploy-on-aws, aws-serverless, databases-on-aws, etc.)

### Safety
- @Oracle (plan-reviewer) BLOCKs twice → escalate to user
- @Fixer stalls 3 iterations → use /diagnose (mattpocock) + pivot
- @code-reviewer BLOCKs twice on same code → escalate to user
- Never: force-push, rm -rf, skip tests
- Trunk-based: all branches squash to 1 commit

### Old Project Guardrails (from flow-kit B3-B5)
- B3: Each card declares read_files + write_files. After @Fixer commits, check git diff. Files outside boundary → rollback.
- B4: Delete ≥5 lines or change public interface → grep all references first, show user, wait for confirm.
- B5: Before writing new code for any capability → grep project for existing implementation first. Found → reuse. Not found → create.
