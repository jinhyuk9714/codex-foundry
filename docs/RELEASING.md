# Releasing

Use this flow when you are cutting an official `codex-foundry` release.

## Release Metadata

- `VERSION` is the single source of truth for the public version.
- `CHANGELOG.md` must contain both `## [Unreleased]` and a release section for the exact `VERSION`.
- `.codex-foundry/manifest.toml` stays on manifest v1 and keeps `source_commit`, not a human-readable release version.

## Prepare the Release

Shell:

```bash
bash scripts/prepare-release.sh --dry-run
```

PowerShell:

```powershell
pwsh -File scripts/prepare-release.ps1 -DryRun
```

The prepare step checks:

- git working tree is clean,
- current branch is `main`,
- `CHANGELOG.md` contains the exact release section for `VERSION`,
- tag `v<version>` does not already exist,
- the full verification suite passes.

## Manual Publish Commands

If the prepare step passes, run the printed commands manually:

```bash
git tag v0.8.0
git push origin main
git push origin v0.8.0
gh release create v0.8.0 --generate-notes
```

Use the real version from `VERSION`, not the example above.

## Maintainer Sequence

1. Update `VERSION`.
2. Move release notes from `Unreleased` into a new dated section in `CHANGELOG.md`.
3. Run `bash scripts/prepare-release.sh --dry-run`.
4. Review the printed commands.
5. Create the tag and GitHub release manually.

## Tagged Upgrade Source

When consumers upgrade from an official release, prefer a tagged checkout:

```bash
git clone https://github.com/jinhyuk9714/codex-foundry.git
cd codex-foundry
git checkout v0.8.0
```

Then use that checkout as the source path for `scripts/upgrade.sh`.
