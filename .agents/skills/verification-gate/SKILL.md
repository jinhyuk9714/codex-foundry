---
name: verification-gate
description: Use before claiming completion, readiness, or correctness; run the exact commands that prove the current state and report their real output.
---

# Verification Gate

Do not claim success without fresh evidence.

## Process

1. Identify the command that proves the claim.
2. If `docs/STACK-PROFILE.md` exists, prefer its stack-specific verification commands before the generic repo checks.
3. Run it now.
4. Read the full output and exit code.
5. Report the actual result, not the expected one.
6. If verification fails, describe the failure and the next corrective step.

## Default Repo Commands

- `bash tests/validate_repo.sh`
- `bash tests/bootstrap_safety.sh`
- `bash tests/profile_smoke.sh`
- `bash tests/doctor_smoke.sh`
- `bash tests/upgrade_smoke.sh`

## Rules

- No "should pass now" language.
- No completion claims from stale output.
- Partial verification does not justify a global success claim.
