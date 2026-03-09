# First Steps

Use this checklist when you open `codex-foundry` in Codex CLI or the Codex app for the first time.

## 1. Confirm the Repo Context

- Open the repository root.
- Read the root `AGENTS.md`.
- Run `$codex-setup-check`.
- Run `bash scripts/codex-doctor.sh`.
- If you prefer PowerShell, run `pwsh -File scripts/codex-doctor.ps1`.

## 2. Pick the Right Entry Skill

- Open [Prompt Playbooks](PROMPT-PLAYBOOKS.md).
- Choose `Bootstrap Playbook`, `Feature Playbook`, or `Bugfix Playbook`.
- Paste the first block from the playbook you actually need.

## 3. Stay on the Default Path

For feature work, use this sequence:

1. `$feature-design`
2. `$implementation-plan`
3. `$tdd-implement`
4. `$request-code-review`
5. `$verification-gate`
6. `$finish-branch`

If you want the copy-paste version of that flow, use [Prompt Playbooks](PROMPT-PLAYBOOKS.md#feature-playbook).

## 4. Enable Optional Config Only If Needed

- Review `.codex/config.example.toml`.
- Review `.codex/mcp/README.md`.
- Opt in to `openaiDeveloperDocs` or `context7` only when they add value for the repo.
- Review `docs/ADVANCED-CODEX-POWER.md` only if you want the experimental multi-agent layer.
- Use [Prompt Playbooks](PROMPT-PLAYBOOKS.md#bootstrap-playbook) if you want the shortest onboarding path.

## 5. Verify Before You Trust the Kit

```bash
bash scripts/codex-doctor.sh
bash tests/validate_repo.sh
bash tests/bootstrap_safety.sh
```
