---
name: implementation-plan
description: Use after a design is approved to create a decision-complete implementation plan with exact changes, tests, and assumptions.
---

# Implementation Plan

Convert an approved design into an implementation plan that another engineer can execute without making product decisions.

## Process

1. Re-read the approved design and repo context.
2. Break the work into grouped changes by behavior or subsystem.
3. Name the public interfaces, file paths, and verification commands that matter.
4. Call out edge cases, failure modes, and explicit non-goals only when they prevent mistakes.
5. End with clear assumptions and defaults.

## Rules

- Be concrete about what changes.
- Keep plans concise, but decision complete.
- Do not mix implementation into the plan.
