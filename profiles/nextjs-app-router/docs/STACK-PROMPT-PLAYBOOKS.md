# Stack Prompt Playbooks

Profile ID: nextjs-app-router

Use these prompts together with `docs/STACK-PROFILE.md`.

## Bootstrap Playbook

```text
$codex-setup-check
Use docs/STACK-PROFILE.md as the active nextjs-app-router overlay. Confirm the repo-local setup and the stack-specific assumptions before I start work.
```

Expected response direction:
- confirms the base kit is healthy
- confirms the Next.js overlay is active
- points at the next command or playbook

## Feature Playbook

```text
$feature-design
Use docs/STACK-PROFILE.md as the active nextjs-app-router overlay. I want to add <feature>. Constraints: respect App Router structure, server/client boundaries, and existing loading or error patterns.
```

```text
$implementation-plan
Turn the approved Next.js App Router design for <feature> into a decision-complete implementation plan. Use docs/STACK-PROFILE.md for file placement and verification.
```

```text
$tdd-implement
Implement the approved Next.js App Router plan for <feature>. Follow docs/STACK-PROFILE.md for file placement and verification commands.
```

## Bugfix Playbook

```text
$systematic-debug
Use docs/STACK-PROFILE.md as the active nextjs-app-router overlay. The bug is: <symptom>. Expected behavior: <expected result>. How to reproduce: <route, action, or failing command>.
```

```text
$tdd-implement
Add the regression test for <bug>, then implement the Next.js App Router fix using docs/STACK-PROFILE.md.
```
