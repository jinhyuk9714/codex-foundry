---
name: feature-design
description: Use when starting a new feature or behavior change that needs scope, tradeoffs, and an approved design before implementation.
---

# Feature Design

Turn a rough request into an approved design before any code is written.

## Process

1. Inspect the repo, docs, and current behavior first.
2. If `docs/STACK-PROFILE.md` exists, use it as the active stack overlay before proposing stack-specific structure or commands.
3. State the goal, success criteria, constraints, and anything still ambiguous.
4. Ask only the questions that materially change the design.
5. Present 2 or 3 approaches with a recommendation.
6. Write a compact design covering scope, key changes, risks, and test strategy.
7. Stop and get approval before implementation or planning.

## Rules

- Do not jump into code.
- Do not silently fill in product-level decisions when the user has not made them.
- Prefer removing scope over designing speculative flexibility.
