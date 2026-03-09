# Workflows

This kit focuses on a small number of repeatable, high-signal workflows.

If you want copy-paste prompts instead of the conceptual workflow summaries below, use [Prompt Playbooks](PROMPT-PLAYBOOKS.md).

## Feature Flow

Use this sequence for new capabilities:

1. `feature-design`
2. `implementation-plan`
3. `tdd-implement`
4. `request-code-review`
5. `verification-gate`
6. `finish-branch`

### What Each Step Does

- `feature-design`: turns a rough idea into an approved design.
- `implementation-plan`: converts the approved design into a decision-complete plan.
- `tdd-implement`: executes one verified red-green-refactor step at a time.
- `request-code-review`: reviews the change for bugs, regressions, and missing coverage.
- `verification-gate`: blocks completion claims until fresh commands prove the state.
- `finish-branch`: summarizes change scope, risks, and the next integration step.

Use [Prompt Playbooks](PROMPT-PLAYBOOKS.md#feature-playbook) for the copy-paste version.

## Bug Fix Flow

Use this sequence when behavior is broken or uncertain:

1. `systematic-debug`
2. `tdd-implement`
3. `request-code-review`
4. `verification-gate`
5. `finish-branch`

### Debugging Expectations

- `systematic-debug` must reproduce the problem before proposing a fix.
- `tdd-implement` adds the regression test before the code change.
- `verification-gate` reruns the exact commands that prove the bug is fixed.

Use [Prompt Playbooks](PROMPT-PLAYBOOKS.md#bugfix-playbook) for the copy-paste version.

## Setup Flow

Use `codex-setup-check` at the start of a session, after bootstrap, or when Codex behavior seems off.

It confirms:

- the root `AGENTS.md` exists,
- all eight repo-local skills are present,
- `.codex/config.example.toml` exists,
- skill metadata exists under `.agents/skills/*/agents/openai.yaml`,
- `.codex/mcp/README.md` documents the optional MCP setup,
- any opt-in `.codex/config.multi-agent.example.toml` references valid role configs,
- the repo verification commands are clear.

Use [Prompt Playbooks](PROMPT-PLAYBOOKS.md#bootstrap-playbook) for the copy-paste setup flow.

## Advanced Review Flow

When a change is large enough to benefit from role splitting, opt into the advanced layer and ask Codex to coordinate:

1. `codex-setup-check`
2. `request-code-review`
3. `verification-gate`

Recommended role split:

- `explorer` maps the affected paths and gathers evidence
- `reviewer` finds correctness, regression, and security risks
- `docs_researcher` verifies API behavior with the docs MCP server

## Skill Catalog

- `feature-design`
- `implementation-plan`
- `tdd-implement`
- `systematic-debug`
- `request-code-review`
- `verification-gate`
- `finish-branch`
- `codex-setup-check`
