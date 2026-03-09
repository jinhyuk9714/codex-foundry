# Setup Doctor

`codex-foundry` ships with an execution-focused doctor so you can check the repository state before you start debugging Codex behavior by hand.

## Entrypoints

Shell:

```bash
bash scripts/codex-doctor.sh
```

PowerShell:

```powershell
pwsh -File scripts/codex-doctor.ps1
```

## What It Checks

- required repo-local files such as `AGENTS.md`, the 8 skills, and each `agents/openai.yaml`
- minimal `.codex` examples
- advanced multi-agent example files and role config references
- project-scoped `.codex/config.toml` hints
- environment readiness for `codex`, `git`, `npx`, and `pwsh`
- MCP-related hints when `context7` is configured

## PASS / WARN / FAIL

- `PASS`: the expected file or environment condition is present
- `WARN`: the repo can still work, but something is optional, experimental, or easy to misunderstand
- `FAIL`: the current repo state is incomplete or internally inconsistent

The doctor prints every check before it exits. It does not stop on the first problem.

## CLI and App Interpretation

- In Codex CLI, use the doctor first, then follow up with `/status`, `/debug-config`, or `/mcp` when the output points at configuration or MCP issues.
- In the Codex app, run the doctor from the repo terminal. If the doctor suggests CLI-only follow-up commands, open the same repo in Codex CLI and run them there.
- If `.codex/config.toml` exists, remember that project-scoped config only applies when the project is trusted.

## Common Problems

Missing skill or metadata files:
- Run `bash tests/validate_repo.sh`
- Re-run `bash scripts/codex-doctor.sh`

Project config seems ignored:
- Confirm the project is trusted
- Run `/status`
- Run `/debug-config`

MCP or docs lookups are unavailable:
- Run `/mcp`
- If `context7` is configured, confirm `npx` is available on the machine

Multi-agent config was copied but roles do not work:
- Check `.codex/agents/*.toml`
- Run `/debug-config`

## Expected Output Shape

The interface is intentionally small and stable:

```text
[PASS] <check>
[WARN] <check>
[FAIL] <check>
Summary: <pass> pass, <warn> warn, <fail> fail
```
