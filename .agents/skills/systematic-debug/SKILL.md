---
name: systematic-debug
description: Use when a bug, failing test, broken script, or unclear behavior needs reproduction, diagnosis, and a verified fix.
---

# Systematic Debug

Debug with evidence, not guesses.

## Process

1. Reproduce the failure and capture the exact symptom.
2. If `docs/STACK-PROFILE.md` exists, use it to choose the right runtime path, layout, and verification command for the active stack.
3. Narrow the scope to the smallest failing path.
4. Form one hypothesis at a time and test it.
5. Confirm the root cause before changing code.
6. Add or update a regression test before the fix.
7. Re-run the failing path and the surrounding verification after the fix.

## Rules

- Do not fix by intuition alone.
- Do not change multiple variables at once.
- If you cannot reproduce it, say that clearly and keep investigating.
