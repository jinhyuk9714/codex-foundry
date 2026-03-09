---
name: tdd-implement
description: Use when implementing an approved feature or bugfix; write a failing test first, watch it fail, then add the minimum code to pass.
---

# TDD Implement

Follow a strict red-green-refactor loop.

## Process

1. Choose the smallest next behavior from the approved plan.
2. Write one failing test for that behavior.
3. Run the test and confirm the failure is the expected one.
4. Write the minimum production change that makes the test pass.
5. Re-run the same test, then any broader checks affected by the change.
6. Refactor only while tests stay green.
7. Repeat for the next behavior.

## Rules

- No production code before a failing test.
- For docs or config-heavy work, write the smallest validation script first.
- Do not batch multiple behaviors into one large step.
