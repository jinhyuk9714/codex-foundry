---
name: verification-gate
description: Use before claiming completion, readiness, or correctness; run the exact commands that prove the current state and report their real output.
---

# Verification Gate

Do not claim success without fresh evidence.

## Process

1. Identify the command that proves the claim.
2. Run it now.
3. Read the full output and exit code.
4. Report the actual result, not the expected one.
5. If verification fails, describe the failure and the next corrective step.

## Default Repo Commands

- `bash tests/validate_repo.sh`
- `bash tests/bootstrap_safety.sh`

## Rules

- No "should pass now" language.
- No completion claims from stale output.
- Partial verification does not justify a global success claim.
