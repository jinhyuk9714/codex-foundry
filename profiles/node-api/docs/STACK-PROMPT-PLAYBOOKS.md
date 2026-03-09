# Stack Prompt Playbooks

Profile ID: node-api

Use these prompts together with `docs/STACK-PROFILE.md`.

## Bootstrap Playbook

```text
$codex-setup-check
Use docs/STACK-PROFILE.md as the active node-api overlay. Confirm the repo-local setup and the API-specific assumptions before I start work.
```

Expected response direction:
- confirms the base kit is healthy
- confirms the Node API overlay is active
- points at the next command or playbook

## Feature Playbook

```text
$feature-design
Use docs/STACK-PROFILE.md as the active node-api overlay. I want to add <feature>. Constraints: keep request validation, response shape, status codes, and existing middleware conventions consistent.
```

```text
$implementation-plan
Turn the approved node-api design for <feature> into a decision-complete implementation plan. Use docs/STACK-PROFILE.md for route placement and verification.
```

```text
$tdd-implement
Implement the approved node-api plan for <feature>. Follow docs/STACK-PROFILE.md for endpoint structure and verification commands.
```

## Bugfix Playbook

```text
$systematic-debug
Use docs/STACK-PROFILE.md as the active node-api overlay. The bug is: <symptom>. Expected behavior: <expected result>. How to reproduce: <request, route, or failing command>.
```

```text
$tdd-implement
Add the regression test for <bug>, then implement the node-api fix using docs/STACK-PROFILE.md.
```
