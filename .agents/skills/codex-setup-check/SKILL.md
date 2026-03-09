---
name: codex-setup-check
description: Use at the start of a session or after bootstrap to confirm repo-local guidance, skills, optional config files, and verification commands are in place.
---

# Codex Setup Check

Confirm that the repository is ready for Codex to work the intended way.

## Checklist

1. Confirm the root `AGENTS.md` exists and is non-empty.
2. Confirm all required repo-local skills exist under `.agents/skills`.
3. Confirm each skill has `agents/openai.yaml` metadata with at least `display_name`, `short_description`, and `default_prompt`.
4. Confirm `.codex/config.example.toml` exists.
5. Confirm `.codex/mcp/README.md` exists and documents optional MCP setup.
6. If `.codex/config.multi-agent.example.toml` exists, confirm the referenced `.codex/agents/*.toml` files exist and the role names line up.
7. Confirm the default verification commands are available.
8. Report any missing pieces with the smallest corrective action.

## Rules

- Prefer reporting concrete missing paths over vague setup advice.
- Do not modify `~/.codex` automatically.
- Treat repo-local setup as the source of truth for this kit.
- Treat the advanced multi-agent layer as optional unless the repo has opted into it.
