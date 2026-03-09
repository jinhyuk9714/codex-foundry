---
name: systematic-debug
description: Use when a bug, failing test, broken script, or unclear behavior needs reproduction, diagnosis, and a verified fix.
---

# Systematic Debug

Debug with evidence, not guesses.

## Process

1. Reproduce the failure and capture the exact symptom.
2. Narrow the scope to the smallest failing path.
3. Form one hypothesis at a time and test it.
4. Confirm the root cause before changing code.
5. Add or update a regression test before the fix.
6. Re-run the failing path and the surrounding verification after the fix.

## Rules

- Do not fix by intuition alone.
- Do not change multiple variables at once.
- If you cannot reproduce it, say that clearly and keep investigating.
