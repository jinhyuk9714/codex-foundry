# codex-foundry

[![Template Repository](https://img.shields.io/badge/template-repository-0ea5e9?style=flat-square)](https://github.com/jinhyuk9714/codex-foundry/generate)
[![MIT License](https://img.shields.io/badge/license-MIT-16a34a?style=flat-square)](LICENSE)
[![Codex](https://img.shields.io/badge/Codex-CLI%2FApp-111827?style=flat-square)](https://developers.openai.com/codex/)
[![Repo-local](https://img.shields.io/badge/repo--local-self--contained-7c3aed?style=flat-square)](https://developers.openai.com/codex/concepts/customization/)

Repo-local, self-contained starter kit for Codex skills, workflows, and bootstrap setup.

`codex-foundry` packages a small, opinionated Codex baseline: `AGENTS.md`, repo-local skills in `.agents/skills`, opt-in `.codex` examples, and safe bootstrap scripts for existing repositories.

## What You Get

- A short root `AGENTS.md` with strong default rules.
- Eight repo-local skills:
  - `feature-design`
  - `implementation-plan`
  - `tdd-implement`
  - `systematic-debug`
  - `request-code-review`
  - `verification-gate`
  - `finish-branch`
  - `codex-setup-check`
- Opt-in Codex examples in `.codex/config.example.toml` and `.codex/mcp/README.md`.
- Bootstrap scripts for bringing the kit into an existing repository without overwriting files by default.

## Quick Start

### Option 1: Use This As a Template Repo

1. Create a new repository from this template.
2. Open the repository root in Codex CLI or the Codex app.
3. Run `$codex-setup-check`.
4. Start work with the default feature flow:
   - `$feature-design`
   - `$implementation-plan`
   - `$tdd-implement`
   - `$request-code-review`
   - `$verification-gate`
5. Wrap up with `$finish-branch`.

### Option 2: Inject Into an Existing Repo

```bash
bash scripts/bootstrap.sh --target /path/to/existing-repo --dry-run
bash scripts/bootstrap.sh --target /path/to/existing-repo
```

PowerShell is also supported:

```powershell
pwsh -File .\scripts\bootstrap.ps1 -Target C:\path\to\existing-repo -DryRun
pwsh -File .\scripts\bootstrap.ps1 -Target C:\path\to\existing-repo
```

## Default Workflow

| Goal | Codex-native flow |
| --- | --- |
| New feature | `feature-design` -> `implementation-plan` -> `tdd-implement` -> `request-code-review` -> `verification-gate` |
| Bug fix | `systematic-debug` -> `tdd-implement` -> `request-code-review` -> `verification-gate` |
| End-of-task wrap-up | `finish-branch` |
| Session sanity check | `codex-setup-check` |

## Claude Forge Translation

This kit does not try to recreate slash commands. Instead, it maps the same intent to Codex skills.

| Claude-style habit | Codex habit |
| --- | --- |
| `/plan` | `$feature-design` then `$implementation-plan` |
| `/tdd` | `$tdd-implement` |
| `/code-review` | `$request-code-review` |
| `/handoff-verify` | `$verification-gate` |
| `/explore bug` | `$systematic-debug` |
| `/wrap-up` | `$finish-branch` |
| `/doctor` | `$codex-setup-check` |

## Repository Layout

```text
.
├── AGENTS.md
├── .agents/skills/
├── .codex/config.example.toml
├── .codex/mcp/README.md
├── docs/
├── scripts/bootstrap.sh
├── scripts/bootstrap.ps1
└── tests/
```

## Verification

Run the repo checks before claiming the kit is ready:

```bash
bash tests/validate_repo.sh
bash tests/bootstrap_safety.sh
```

## Docs

- [First Steps](docs/FIRST-STEPS.md)
- [Workflows](docs/WORKFLOWS.md)
- [Customization](docs/CUSTOMIZATION.md)
