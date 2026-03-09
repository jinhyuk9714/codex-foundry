# Stack Prompt Playbooks

Profile ID: python-service

Use these prompts together with `docs/STACK-PROFILE.md`.

## Bootstrap Playbook

```text
$codex-setup-check
Use docs/STACK-PROFILE.md as the active python-service overlay. Confirm the repo-local setup and the service-specific assumptions before I start work.
```

Expected response direction:
- confirms the base kit is healthy
- confirms the Python service overlay is active
- points at the next command or playbook

## Feature Playbook

```text
$feature-design
Use docs/STACK-PROFILE.md as the active python-service overlay. I want to add <feature>. Constraints: keep the service HTTP-oriented, match existing schema patterns, and preserve the repo's sync or async style.
```

```text
$implementation-plan
Turn the approved python-service design for <feature> into a decision-complete implementation plan. Use docs/STACK-PROFILE.md for module placement and verification.
```

```text
$tdd-implement
Implement the approved python-service plan for <feature>. Follow docs/STACK-PROFILE.md for test, lint, and type-check commands.
```

## Bugfix Playbook

```text
$systematic-debug
Use docs/STACK-PROFILE.md as the active python-service overlay. The bug is: <symptom>. Expected behavior: <expected result>. How to reproduce: <request, failing test, or service command>.
```

```text
$tdd-implement
Add the regression test for <bug>, then implement the python-service fix using docs/STACK-PROFILE.md.
```
