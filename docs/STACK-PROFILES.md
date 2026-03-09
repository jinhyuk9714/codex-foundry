# Stack Profiles

`codex-foundry` can stay generic, or you can inject one stack-specific overlay when the repository clearly matches a supported stack.

Only one stack profile should be active at a time.

## Supported Profiles

- `nextjs-app-router`: Next.js applications using the App Router, route handlers, and mixed server/client React.
- `node-api`: general JavaScript or TypeScript HTTP APIs such as Express, Fastify, or similar server layouts.
- `python-service`: Python HTTP services, with FastAPI-style structure as the default reference point.

## Apply a Profile in a Template-Based Repo

If you created a new repo from the template, the source profiles are already present under `profiles/`.

Copy one profile into the active overlay paths:

```bash
cp profiles/nextjs-app-router/docs/STACK-PROFILE.md docs/STACK-PROFILE.md
cp profiles/nextjs-app-router/docs/STACK-PROMPT-PLAYBOOKS.md docs/STACK-PROMPT-PLAYBOOKS.md
```

Then run:

```text
$codex-setup-check
```

```bash
bash scripts/codex-doctor.sh
```

## Apply a Profile While Bootstrapping an Existing Repo

Use `--profile` to inject the base kit and one stack overlay together.

```bash
bash /path/to/codex-foundry/scripts/bootstrap.sh --source /path/to/codex-foundry --target . --profile nextjs-app-router --dry-run
bash /path/to/codex-foundry/scripts/bootstrap.sh --source /path/to/codex-foundry --target . --profile nextjs-app-router
```

PowerShell:

```powershell
pwsh -File C:\path\to\codex-foundry\scripts\bootstrap.ps1 -Source C:\path\to\codex-foundry -Target . -Profile nextjs-app-router -DryRun
pwsh -File C:\path\to\codex-foundry\scripts\bootstrap.ps1 -Source C:\path\to\codex-foundry -Target . -Profile nextjs-app-router
```

## What a Profile Injects

- `docs/STACK-PROFILE.md`: stack-specific structure, guardrails, and verification commands
- `docs/STACK-PROMPT-PLAYBOOKS.md`: stack-specific bootstrap, feature, and bugfix prompts

The base kit still stays in place. Profiles do not replace the 8 skills, the doctor scripts, or the `.codex` examples.

## After You Apply a Profile

- Read `docs/STACK-PROFILE.md` before choosing stack-specific commands or file placement.
- Use `docs/STACK-PROMPT-PLAYBOOKS.md` if you want copy-paste prompts tuned for that stack.
- Re-run `$codex-setup-check` and `bash scripts/codex-doctor.sh` after the overlay is in place.
