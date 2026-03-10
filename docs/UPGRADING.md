# Upgrading

Use the upgrade path when a repository already has `codex-foundry` and you want a newer upstream version without overwriting local edits by accident.

## Entry Points

Shell:

```bash
bash scripts/upgrade.sh --source /path/to/codex-foundry --target .
```

Tagged source checkout example:

```bash
git clone https://github.com/jinhyuk9714/codex-foundry.git
cd codex-foundry
git checkout v0.8.0
bash scripts/upgrade.sh --source "$PWD" --target /path/to/your-repo
```

PowerShell:

```powershell
pwsh -File scripts/upgrade.ps1 -Source C:\path\to\codex-foundry -Target .
```

## How It Works

- `.codex-foundry/manifest.toml` stores the managed baseline for this repo.
- `source_commit` records which source snapshot the managed state came from.
- Each managed file record stores `path` and `sha256`.
- Upgrades only replace files that still match the recorded checksum.

## Normal Upgrade

Use the normal path when the repo already has `.codex-foundry/manifest.toml`.

```bash
bash scripts/upgrade.sh --source /path/to/codex-foundry --target .
```

What happens:

- Files that still match the manifest checksum are safe to update.
- New managed files from the source can be added automatically.
- Files with local edits are reported as a conflict and are not overwritten.
- If any conflict exists, the script exits non-zero after reporting it.

## Legacy Repos and `--adopt`

Older repos may not have `.codex-foundry/manifest.toml` yet. In that case, do not force an upgrade. Adopt the existing files first.

```bash
bash scripts/upgrade.sh --source /path/to/codex-foundry --target . --adopt
```

PowerShell:

```powershell
pwsh -File scripts/upgrade.ps1 -Source C:\path\to\codex-foundry -Target . -Adopt
```

`--adopt` or `-Adopt`:

- discovers the canonical managed files that already exist in the target repo,
- records their current checksums in `.codex-foundry/manifest.toml`,
- does not overwrite tracked repo files,
- lets you run the normal upgrade command afterward.

## Conflict Handling

Conflict policy is intentionally strict:

- local drift in a managed file => report the conflict and refuse to overwrite it,
- missing managed file => report the conflict and refuse to guess,
- unknown profile or mismatched tracked profile => fail fast,
- no auto-merge, no forced overwrite, no backup file spam.

Resolve the local edit yourself, then run the upgrade again.

## Profiles

If the repo uses a stack overlay, the manifest tracks `active_profile`.

- Upgrades keep that profile fixed.
- `--profile` or `-Profile` is only a guard during tracked upgrades.
- Profile switching is out of scope for this path.
- Profile-aware upgrades refresh `docs/STACK-PROFILE.md` and `docs/STACK-PROMPT-PLAYBOOKS.md` from the matching source profile.

## Recommended Sequence

1. Run `$codex-setup-check`.
2. Run `bash scripts/codex-doctor.sh`.
3. If the doctor warns that the manifest is missing, run the adopt command once.
4. Run the normal upgrade command.
5. Re-run:

```bash
bash scripts/codex-doctor.sh
bash tests/validate_repo.sh
bash tests/bootstrap_safety.sh
bash tests/profile_smoke.sh
bash tests/doctor_smoke.sh
bash tests/upgrade_smoke.sh
```
