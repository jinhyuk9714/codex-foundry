# codex-foundry

[![Template Repository](https://img.shields.io/badge/template-repository-0ea5e9?style=flat-square)](https://github.com/jinhyuk9714/codex-foundry/generate)
[![MIT License](https://img.shields.io/badge/license-MIT-16a34a?style=flat-square)](LICENSE)
[![Codex](https://img.shields.io/badge/Codex-CLI%2FApp-111827?style=flat-square)](https://developers.openai.com/codex/)
[![Repo-local](https://img.shields.io/badge/repo--local-self--contained-7c3aed?style=flat-square)](https://developers.openai.com/codex/concepts/customization/)
[![repo-ci](https://github.com/jinhyuk9714/codex-foundry/actions/workflows/repo-ci.yml/badge.svg)](https://github.com/jinhyuk9714/codex-foundry/actions/workflows/repo-ci.yml)

English | [한국어](README.ko.md)

[Quick Start](#start-here) • [Workflow](#default-workflow) • [Docs](#docs) • [Upgrade](docs/UPGRADING.md)

Template note: this CI badge belongs to the upstream template repo. Replace or remove it after you use this template in your own repository.

Repo-local, self-contained starter kit for Codex skills, workflows, and bootstrap setup.

`codex-foundry` is a GitHub template for people who want Codex to behave the same way in every repository. It keeps the important parts local: a focused `AGENTS.md`, eight stable skills, opt-in `.codex` examples, and safe bootstrap scripts for existing codebases.

## What It Is

`codex-foundry` is not an app you run. It is the repo-local layer you copy into a project so Codex sees the same rules, skills, and setup flow every time.

- `AGENTS.md` sets the repo-level rules.
- `.agents/skills/` gives Codex repeatable workflows with stable names.
- `.codex/` and `profiles/` stay opt-in, so the default setup stays small.
- `scripts/bootstrap.sh` and `scripts/bootstrap.ps1` inject the kit into an existing repo without overwriting files by default.

## Start Here

Choose one path.

### Start a New Project

Use this when `codex-foundry` is the base of a brand new repository.

1. Open [codex-foundry](https://github.com/jinhyuk9714/codex-foundry).
2. Click `Use this template`.
3. Create your repository, then clone it.

```bash
git clone <your-new-repo-url>
cd <your-new-repo-name>
```

4. Open the repo in Codex CLI or the Codex app.
5. Run the first repo check:

```text
$codex-setup-check
```

6. Run the executable setup diagnosis:

```bash
bash scripts/codex-doctor.sh
```

Need prompts fast? Open [Prompt Playbooks](docs/PROMPT-PLAYBOOKS.md). Need a stack overlay? Open [Stack Profiles](docs/STACK-PROFILES.md). Updating an older install? Use [Upgrading](docs/UPGRADING.md).

Then start with the default path:

```text
$feature-design
$implementation-plan
$tdd-implement
```

### Add It to an Existing Repository

Use this when you already have a repository and want to inject the kit into it.

Preview the copy first:

```bash
bash /path/to/codex-foundry/scripts/bootstrap.sh --source /path/to/codex-foundry --target . --dry-run
```

Apply it when the preview looks right:

```bash
bash /path/to/codex-foundry/scripts/bootstrap.sh --source /path/to/codex-foundry --target .
```

Need a stack overlay at bootstrap time? Add `--profile`:

```bash
bash /path/to/codex-foundry/scripts/bootstrap.sh --source /path/to/codex-foundry --target . --profile nextjs-app-router
```

Then run:

```text
$codex-setup-check
```

```bash
bash scripts/codex-doctor.sh
```

Need prompts fast? Open [Prompt Playbooks](docs/PROMPT-PLAYBOOKS.md). If this repo already contains `codex-foundry`, use [Upgrading](docs/UPGRADING.md) instead of running bootstrap again.

PowerShell works too:

```powershell
pwsh -File C:\path\to\codex-foundry\scripts\bootstrap.ps1 -Source C:\path\to\codex-foundry -Target . -DryRun
pwsh -File C:\path\to\codex-foundry\scripts\bootstrap.ps1 -Source C:\path\to\codex-foundry -Target .
pwsh -File scripts\codex-doctor.ps1
```

## Default Workflow

For copy-paste versions of these flows, use [Prompt Playbooks](docs/PROMPT-PLAYBOOKS.md). If a stack overlay is active, read `docs/STACK-PROFILE.md` before planning.

- New feature: `feature-design` -> `implementation-plan` -> `tdd-implement` -> `request-code-review` -> `verification-gate`
- Bug fix: `systematic-debug` -> `tdd-implement` -> `request-code-review` -> `verification-gate`
- Wrap-up after verified work: `finish-branch`
- Session or bootstrap sanity check: `codex-setup-check`

## Advanced Codex Power

The default kit stays small. If a repository needs role-based review or docs verification, the advanced layer is there when you want it.

- Stay with `.codex/config.example.toml` if you only want the minimal repo-local baseline.
- Copy the advanced example when you want the experimental multi-agent layer:

```bash
cp .codex/config.multi-agent.example.toml .codex/config.toml
```

- That enables the `explorer`, `reviewer`, and `docs_researcher` role setup.
- See [Advanced Codex Power](docs/ADVANCED-CODEX-POWER.md) for the full notes and prompt examples.

## What's Included

- `AGENTS.md` for repo-level Codex rules.
- Eight repo-local skills: `feature-design`, `implementation-plan`, `tdd-implement`, `systematic-debug`, `request-code-review`, `verification-gate`, `finish-branch`, `codex-setup-check`.
- Minimal `.codex` examples plus an opt-in multi-agent layer.
- `scripts/codex-doctor.sh` and `scripts/codex-doctor.ps1` for executable setup diagnosis.
- `scripts/upgrade.sh`, `scripts/upgrade.ps1`, and `.codex-foundry/manifest.toml` for safe updates.
- `VERSION`, `CHANGELOG.md`, `scripts/prepare-release.sh`, and [Releasing](docs/RELEASING.md) for release discipline.
- [Prompt Playbooks](docs/PROMPT-PLAYBOOKS.md) and [Stack Profiles](docs/STACK-PROFILES.md) for faster onboarding.
- `scripts/bootstrap.sh` and `scripts/bootstrap.ps1` for safe injection into existing repos.

## Docs

- [First Steps](docs/FIRST-STEPS.md)
- [Prompt Playbooks](docs/PROMPT-PLAYBOOKS.md)
- [Stack Profiles](docs/STACK-PROFILES.md)
- [Workflows](docs/WORKFLOWS.md)
- [Customization](docs/CUSTOMIZATION.md)
- [Upgrading](docs/UPGRADING.md)
- [Releasing](docs/RELEASING.md)
- [Advanced Codex Power](docs/ADVANCED-CODEX-POWER.md)
- [Setup Doctor](docs/SETUP-DOCTOR.md)
