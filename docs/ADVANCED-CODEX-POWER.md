# Advanced Codex Power

`codex-foundry` keeps the default path small. The advanced layer is opt-in and meant for repositories that benefit from Codex-native role specialization.

## When to Enable It

Enable the multi-agent example when you have work that is easier to split into focused read-only roles, such as:

- PR or branch review across a non-trivial diff
- framework or API migrations that need documentation confirmation
- larger changes where one agent should map code paths before another reviews risk

Keep the default single-agent workflow for straightforward feature work and small bug fixes.

## Files in the Advanced Layer

- `.codex/config.multi-agent.example.toml`
- `.codex/agents/explorer.toml`
- `.codex/agents/reviewer.toml`
- `.codex/agents/docs-researcher.toml`

## How to Opt In

1. Copy the advanced example into the project-scoped config file.

```bash
cp .codex/config.multi-agent.example.toml .codex/config.toml
```

2. Review the role TOML files in `.codex/agents/` and adjust them only if your repo needs different guardrails.
3. Restart Codex or open a new session so the config reloads.

The official Codex docs currently describe multi-agent support as experimental, so this kit keeps it off by default.

## Included Roles

- `explorer`: read-only codebase exploration and evidence gathering
- `reviewer`: correctness, regression, security, and missing-test review
- `docs_researcher`: official docs verification through `openaiDeveloperDocs`

## Prompt Examples

### PR Review Team

```text
Review this branch against main. Have explorer map the affected code paths, reviewer find real risks, and docs_researcher verify the framework APIs that the patch relies on.
```

### Docs Verification Before a Change

```text
Before changing this integration, ask docs_researcher to confirm the API behavior and version-specific options, then have explorer identify the call sites that would be affected.
```

## Why This Stays Opt-In

- the default starter kit should remain simple
- multi-agent behavior is experimental
- not every repository benefits from extra roles or MCP-backed docs checks
