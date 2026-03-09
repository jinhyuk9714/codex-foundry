---
name: codex-setup-check
description: Use at the start of a session or after bootstrap to confirm repo-local guidance, skills, optional config files, and verification commands are in place.
---

# Codex Setup Check

Confirm that the repository is ready for Codex to work the intended way, then route the user into the executable doctor.

## Checklist

1. Confirm the root `AGENTS.md` exists and is non-empty.
2. Confirm all required repo-local skills exist under `.agents/skills`.
3. Confirm each skill has `agents/openai.yaml` metadata with at least `display_name`, `short_description`, and `default_prompt`.
4. Confirm `.codex/config.example.toml` and `.codex/mcp/README.md` exist.
5. Confirm `.codex/config.multi-agent.example.toml` and `.codex/agents/*.toml` are internally consistent when present.
6. If `docs/STACK-PROFILE.md` and `docs/STACK-PROMPT-PLAYBOOKS.md` exist, treat them as the active stack overlay and confirm they are both present together.
7. Tell the user to run `bash scripts/codex-doctor.sh` or `pwsh -File scripts/codex-doctor.ps1` for the executable diagnosis pass.
8. After the doctor, point the user at `docs/PROMPT-PLAYBOOKS.md` or `docs/PROMPT-PLAYBOOKS.ko.md` for generic prompts, and at `docs/STACK-PROFILE.md` if a stack overlay is active.
9. Use the doctor output to point them at the next command, such as `/status`, `/debug-config`, or `/mcp`.
10. Report any missing pieces with the smallest corrective action.

## Rules

- Prefer reporting concrete missing paths over vague setup advice.
- Do not modify `~/.codex` automatically.
- Treat repo-local setup as the source of truth for this kit.
- Treat the advanced multi-agent layer as optional unless the repo has opted into it.
- Prefer the executable doctor over ad-hoc setup advice once the basic files are in place.
