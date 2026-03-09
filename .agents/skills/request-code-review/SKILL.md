---
name: request-code-review
description: Use after a meaningful change to review for bugs, regressions, weak assumptions, and missing tests before calling the work ready.
---

# Request Code Review

Review the change with a bug-finding mindset.

## Process

1. Read the plan or requirements again.
2. Inspect the changed files and the verification evidence.
3. Look first for correctness issues, regressions, risky assumptions, and missing coverage.
4. Report findings ordered by severity with file references.
5. Only after findings, give a short summary or note residual risks.

## Rules

- Findings come first.
- If there are no findings, say that explicitly and still mention test gaps or residual risk.
- If no git history is available, review the working tree directly.
