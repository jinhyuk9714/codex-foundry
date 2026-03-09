# codex-foundry

[![Template Repository](https://img.shields.io/badge/template-repository-0ea5e9?style=flat-square)](https://github.com/jinhyuk9714/codex-foundry/generate)
[![MIT License](https://img.shields.io/badge/license-MIT-16a34a?style=flat-square)](LICENSE)
[![Codex](https://img.shields.io/badge/Codex-CLI%2FApp-111827?style=flat-square)](https://developers.openai.com/codex/)
[![Repo-local](https://img.shields.io/badge/repo--local-self--contained-7c3aed?style=flat-square)](https://developers.openai.com/codex/concepts/customization/)

English | [한국어](README.ko.md)

Repo-local, self-contained starter kit for Codex skills, workflows, and bootstrap setup.

`codex-foundry` is a GitHub template for people who want Codex to behave the same way in every repository. It keeps the important parts local: a focused `AGENTS.md`, eight named skills, opt-in `.codex` examples, and bootstrap scripts for existing codebases.

## What It Is

`codex-foundry` is not an app you run. It is the starting layer you copy into a repo so Codex sees the same instructions, skills, and optional config every time.

- `AGENTS.md` sets the repo-level rules.
- `.agents/skills/` gives Codex repeatable workflows with stable names.
- `.codex/` stays opt-in, so the default setup is still safe and small.
- `profiles/` holds optional stack overlays when the repo matches a supported stack.
- `scripts/bootstrap.sh` and `scripts/bootstrap.ps1` let you add the kit to an existing repository without overwriting files by default.

## Start Here

There are two supported ways to use `codex-foundry`.

### Start a New Project

Use the template when `codex-foundry` is the base of a brand new repository.

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

7. If you want copy-paste prompts, open [Prompt Playbooks](docs/PROMPT-PLAYBOOKS.md).
8. If you want a stack-specific overlay, see [Stack Profiles](docs/STACK-PROFILES.md) and copy one profile into `docs/STACK-PROFILE.md` and `docs/STACK-PROMPT-PLAYBOOKS.md`.
9. Then start work with the default path:

```text
$feature-design
$implementation-plan
$tdd-implement
```

### Add It to an Existing Repository

Use the bootstrap script when you already have a repository and want to inject the kit into it.

1. Keep `codex-foundry` somewhere on your machine.
2. From the existing repository, preview the copy first:

```bash
bash /path/to/codex-foundry/scripts/bootstrap.sh --source /path/to/codex-foundry --target . --dry-run
```

3. Apply it when the preview looks right:

```bash
bash /path/to/codex-foundry/scripts/bootstrap.sh --source /path/to/codex-foundry --target .
```

If you want a stack overlay during bootstrap, add `--profile`:

```bash
bash /path/to/codex-foundry/scripts/bootstrap.sh --source /path/to/codex-foundry --target . --profile nextjs-app-router
```

4. Open that repository in Codex and run:

```text
$codex-setup-check
```

5. Then run:

```bash
bash scripts/codex-doctor.sh
```

6. If you want copy-paste prompts, open [Prompt Playbooks](docs/PROMPT-PLAYBOOKS.md).

PowerShell works too:

```powershell
pwsh -File C:\path\to\codex-foundry\scripts\bootstrap.ps1 -Source C:\path\to\codex-foundry -Target . -DryRun
pwsh -File C:\path\to\codex-foundry\scripts\bootstrap.ps1 -Source C:\path\to\codex-foundry -Target .
pwsh -File scripts\codex-doctor.ps1
```

## Default Workflow

For copy-paste prompt versions of these flows, use [Prompt Playbooks](docs/PROMPT-PLAYBOOKS.md).

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

- `AGENTS.md`: short repo-level rules for Codex.
- Eight repo-local skills: `feature-design`, `implementation-plan`, `tdd-implement`, `systematic-debug`, `request-code-review`, `verification-gate`, `finish-branch`, `codex-setup-check`.
- Minimal `.codex` examples: `.codex/config.example.toml` and `.codex/mcp/README.md`.
- Opt-in multi-agent layer: `.codex/config.multi-agent.example.toml` and `.codex/agents/`.
- Executable doctor scripts: `scripts/codex-doctor.sh` and `scripts/codex-doctor.ps1`.
- Prompt playbooks: `docs/PROMPT-PLAYBOOKS.md` for bootstrap, feature, and bugfix flows.
- Stack profiles: `docs/STACK-PROFILES.md` plus optional injected `docs/STACK-PROFILE.md` and `docs/STACK-PROMPT-PLAYBOOKS.md`.
- Safe bootstrap scripts: `scripts/bootstrap.sh` and `scripts/bootstrap.ps1`.

## Verification

Run the repo checks before claiming the kit is ready:

```bash
bash tests/validate_repo.sh
bash tests/bootstrap_safety.sh
```

## Docs

- [First Steps](docs/FIRST-STEPS.md)
- [Prompt Playbooks](docs/PROMPT-PLAYBOOKS.md)
- [Stack Profiles](docs/STACK-PROFILES.md)
- [Workflows](docs/WORKFLOWS.md)
- [Customization](docs/CUSTOMIZATION.md)
- [Advanced Codex Power](docs/ADVANCED-CODEX-POWER.md)
- [Setup Doctor](docs/SETUP-DOCTOR.md)
