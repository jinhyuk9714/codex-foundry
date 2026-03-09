# Workflows

This kit focuses on a small number of repeatable, high-signal workflows.

## Feature Flow

Use this sequence for new capabilities:

1. `feature-design`
2. `implementation-plan`
3. `tdd-implement`
4. `request-code-review`
5. `verification-gate`
6. `finish-branch`

### What Each Step Does

- `feature-design`: turns a rough idea into an approved design.
- `implementation-plan`: converts the approved design into a decision-complete plan.
- `tdd-implement`: executes one verified red-green-refactor step at a time.
- `request-code-review`: reviews the change for bugs, regressions, and missing coverage.
- `verification-gate`: blocks completion claims until fresh commands prove the state.
- `finish-branch`: summarizes change scope, risks, and the next integration step.

## Bug Fix Flow

Use this sequence when behavior is broken or uncertain:

1. `systematic-debug`
2. `tdd-implement`
3. `request-code-review`
4. `verification-gate`
5. `finish-branch`

### Debugging Expectations

- `systematic-debug` must reproduce the problem before proposing a fix.
- `tdd-implement` adds the regression test before the code change.
- `verification-gate` reruns the exact commands that prove the bug is fixed.

## Setup Flow

Use `codex-setup-check` at the start of a session, after bootstrap, or when Codex behavior seems off.

It confirms:

- the root `AGENTS.md` exists,
- all eight repo-local skills are present,
- `.codex/config.example.toml` exists,
- `.codex/mcp/README.md` documents the optional MCP setup,
- the repo verification commands are clear.

## Skill Catalog

- `feature-design`
- `implementation-plan`
- `tdd-implement`
- `systematic-debug`
- `request-code-review`
- `verification-gate`
- `finish-branch`
- `codex-setup-check`
