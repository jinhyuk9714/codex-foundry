# codex-foundry

[![Template Repository](https://img.shields.io/badge/template-repository-0ea5e9?style=flat-square)](https://github.com/jinhyuk9714/codex-foundry/generate)
[![MIT License](https://img.shields.io/badge/license-MIT-16a34a?style=flat-square)](LICENSE)
[![Codex](https://img.shields.io/badge/Codex-CLI%2FApp-111827?style=flat-square)](https://developers.openai.com/codex/)
[![Repo-local](https://img.shields.io/badge/repo--local-self--contained-7c3aed?style=flat-square)](https://developers.openai.com/codex/concepts/customization/)

English | [한국어](README.ko.md)

Repo-local, self-contained starter kit for Codex skills, workflows, and bootstrap setup.

`codex-foundry` gives you a small, opinionated baseline for Codex: `AGENTS.md`, repo-local skills in `.agents/skills`, opt-in `.codex` examples, and bootstrap scripts for existing repositories.

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
- An opt-in advanced layer for multi-agent role configs in `.codex/config.multi-agent.example.toml` and `.codex/agents/`.
- Bootstrap scripts for bringing the kit into an existing repository without overwriting files by default.

## Getting Started

### Start a New Project From the Template

1. Open [codex-foundry](https://github.com/jinhyuk9714/codex-foundry).
2. Click `Use this template`.
3. Create your new repository.
4. Clone it locally.

```bash
git clone <your-new-repo-url>
cd <your-new-repo-name>
```

5. Open the repo in Codex CLI or the Codex app.
6. Run:

```text
$codex-setup-check
```

7. Start with the default feature flow:

```text
$feature-design
$implementation-plan
$tdd-implement
$request-code-review
$verification-gate
$finish-branch
```

### Add codex-foundry to an Existing Repository

Keep `codex-foundry` somewhere on your machine, then run the bootstrap script from your existing project.

1. Move to your existing repository.
2. Preview the changes first.

```bash
bash /path/to/codex-foundry/scripts/bootstrap.sh --source /path/to/codex-foundry --target . --dry-run
```

3. Apply the files if the preview looks right.

```bash
bash /path/to/codex-foundry/scripts/bootstrap.sh --source /path/to/codex-foundry --target .
```

4. Open the repo in Codex and run:

```text
$codex-setup-check
```

PowerShell is also supported:

```powershell
pwsh -File C:\path\to\codex-foundry\scripts\bootstrap.ps1 -Source C:\path\to\codex-foundry -Target . -DryRun
pwsh -File C:\path\to\codex-foundry\scripts\bootstrap.ps1 -Source C:\path\to\codex-foundry -Target .
```

## Advanced Codex Power

The default kit is intentionally small. If a repository benefits from role-based review or docs verification, `codex-foundry` also ships an opt-in advanced layer.

- Keep `.codex/config.example.toml` when you only want a minimal repo-local baseline.
- Copy `.codex/config.multi-agent.example.toml` to `.codex/config.toml` when you want the experimental `explorer`, `reviewer`, and `docs_researcher` roles.
- See [Advanced Codex Power](docs/ADVANCED-CODEX-POWER.md) for setup notes and prompt examples.

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
├── .codex/config.multi-agent.example.toml
├── .codex/agents/
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
- [Advanced Codex Power](docs/ADVANCED-CODEX-POWER.md)
