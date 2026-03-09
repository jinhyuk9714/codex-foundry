# AGENTS.md

## Default Flow

- Start feature work with `feature-design`, then `implementation-plan`, then `tdd-implement`, then `request-code-review`, then `verification-gate`.
- Use `systematic-debug` for failures, `finish-branch` for wrap-up, and `codex-setup-check` at session start or after bootstrap.

## Working Rules

- Prefer repo-local skills in `.agents/skills` before relying on global skills.
- Do not expand scope without user approval. No drive-by refactors or opportunistic cleanup.
- Do not claim completion without fresh verification output.
- Keep skill names, docs, and examples aligned. If you rename a workflow, update every user-facing reference in the same change.

## Verification

- Run `bash tests/validate_repo.sh`.
- Run `bash tests/bootstrap_safety.sh`.
