# codex-foundry

Repo-local, self-contained Codex starter kit for Codex CLI and the Codex app.

This project takes the "pre-wired workflow" idea from Claude Forge and translates it into Codex-native building blocks: `AGENTS.md`, repo-local skills in `.agents/skills`, and opt-in `.codex` configuration examples.

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
