# Customization

`codex-foundry` is designed to be easy to adapt without breaking its default workflow.

## Root Guidance

Edit `AGENTS.md` when you need durable repo-level rules such as:

- build and test commands,
- review expectations,
- language or framework preferences,
- directory-specific routing guidance.

Keep it short. Put repeatable workflows in skills, not in `AGENTS.md`.

## Repo-local Skills

`codex-foundry` keeps all workflow-critical behavior inside `.agents/skills`.

You can:

- tighten a trigger by editing the skill `description`,
- add references or scripts when a workflow becomes too repetitive,
- create nested `.agents/skills` folders later if a subdirectory needs specialized behavior.

Keep the v1 skill interface stable:

- `feature-design`
- `implementation-plan`
- `tdd-implement`
- `systematic-debug`
- `request-code-review`
- `verification-gate`
- `finish-branch`
- `codex-setup-check`

## Optional Codex Config

`.codex/config.example.toml` is intentionally small.

Use it when you want to:

- opt in to project-local Codex configuration,
- add `openaiDeveloperDocs`,
- add `context7`,
- preserve a documented baseline for the repository.

Do not assume that every contributor wants repo-local `.codex/config.toml`. Keep the example file as the stable template.

## Advanced Codex Power

The role-based multi-agent layer is intentionally separate from the minimal config.

Use the advanced files only when the repository benefits from Codex-native role specialization:

- `.codex/config.multi-agent.example.toml`
- `.codex/agents/explorer.toml`
- `.codex/agents/reviewer.toml`
- `.codex/agents/docs-researcher.toml`

Keep this layer opt-in. Do not replace the minimal example with the advanced one by default.

## Existing Repo Bootstrap

Use `scripts/bootstrap.sh` or `scripts/bootstrap.ps1` when you want to inject `codex-foundry` into an existing repository.

By default the scripts:

- copy only the kit files needed for repo-local usage,
- refuse to overwrite existing files,
- support dry-run output before making changes.

## Updating the Kit

When you add or rename a workflow:

1. Update the relevant `SKILL.md`.
2. Update any matching `agents/openai.yaml` metadata.
2. Update `README.md`.
3. Update `docs/WORKFLOWS.md`.
4. Update any bootstrap path lists and tests.
