# Optional MCP Setup

`codex-foundry` does not modify `~/.codex/config.toml` for you.

The recommended opt-in MCP servers for v1 are:

- `openaiDeveloperDocs`: official Codex and OpenAI docs lookup.
- `context7`: up-to-date library and framework docs lookup.

The advanced multi-agent example in `.codex/config.multi-agent.example.toml` also relies on `openaiDeveloperDocs` through `.codex/agents/docs-researcher.toml`.

## Minimal Example

Use the snippet in `.codex/config.example.toml` as a starting point.

If you want the configuration to be project-local, copy the parts you need into:

```text
.codex/config.toml
```

If you want the configuration to apply everywhere, merge it into:

```text
~/.codex/config.toml
```

## Why It Is Optional

- Some repositories do not need external docs lookup.
- MCP choices are personal and environment-specific.
- This kit stays self-contained and safe by default.

For the optional role-based setup, see `docs/ADVANCED-CODEX-POWER.md`.
