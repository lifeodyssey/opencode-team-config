---
name: team-tdd
description: Team TDD skill. Invoke before any implementation. Combines superpowers iron law, mattpocock vertical slicing, and tech-stack specific constraints.
---

# Team TDD

## Iron Law (from superpowers)

NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST.

Code written before tests → delete it. Not "keep as reference", not "adapt it". Delete and restart from test.

## Workflow (from mattpocock)

### 1. Design First
Before writing any code:
- Confirm with user: what interface changes needed?
- Confirm with user: which behaviors to test? (prioritize)
- List behaviors to test (NOT implementation steps)
- Get user approval

### 2. Vertical Slicing (NOT Horizontal)

WRONG: write all tests → write all code
RIGHT: one test → one implementation → repeat

Each cycle responds to what you learned from the previous one.

```
WRONG (horizontal):
  RED:   test1, test2, test3, test4, test5
  GREEN: impl1, impl2, impl3, impl4, impl5

RIGHT (vertical):
  RED→GREEN: test1→impl1
  RED→GREEN: test2→impl2
  RED→GREEN: test3→impl3
```

### 3. RED-GREEN-REFACTOR Cycle

**RED:** Write ONE test for ONE behavior
- Use the project's existing test runner
- Test name describes behavior: `test_<verb>_<scenario>_<expected>` or `"<verb>s <what> when <condition>"`
- Test uses public interface only
- Run → MUST fail (not error, fail)
- Classify: MISSING_BEHAVIOR (proceed) | TEST_BROKEN (fix test) | ENV_BROKEN (escalate)

**GREEN:** Write MINIMAL code to pass
- Only enough for THIS test
- Don't anticipate future tests
- Run → MUST pass. 3 failures → escalate.

**REFACTOR:** Clean up while tests stay green. Apply constraints below.

### 4. General Constraints (all languages)
- Functions: ≤10 lines (excluding signature). Extract if longer.
- Classes/Components: ≤50-100 lines. Split by responsibility.
- Files: ≤300 lines.
- Max 2 indentation levels (flatten with early return).
- Max 3 params per function → parameter object if more.
- Mock only at boundaries (DB/HTTP/external APIs).
- One test file per production module. Max 200 lines per test file.
- Factory functions for test data: `make_xxx()` / `createXxx()`
- Single responsibility per function/class/module.
- Early return. No else after return/raise/continue.

### 5. Per-Stack Rules (loaded via Orchestrator annotation)
- React/TS: load vercel-react-best-practices + next-best-practices + frontend-tdd
- Kotlin/Spring: load kotlin-agent-skills (JetBrains) + dr-jskill
- Terraform: load terraform-skill
- AWS: load awslabs agent-plugins
- Postgres: load pg-aiguide (Timescale)

### 6. Commit
- `git add <specific files>` (never -A)
- Atomic commit per RED→GREEN→REFACTOR cycle
- Message: `<type>(<scope>): <description>`

## Red Flags (from superpowers) — Require Code Deletion and Restart
- Writing code before tests
- Tests passing immediately without failing first
- Any rationalization for "just this once"
- Keeping previous code as reference
- Delayed test creation
- Adding tests post-implementation
- Claims about "spirit versus ritual"

## Checklist Per Cycle
- [ ] Test describes behavior, not implementation
- [ ] Test uses public interface only
- [ ] Test would survive internal refactor
- [ ] Test was observed FAILING before GREEN
- [ ] Code is minimal for this test
- [ ] No speculative features added
- [ ] Tech-stack constraints applied in REFACTOR
- [ ] Commit is atomic (one behavior per commit)
