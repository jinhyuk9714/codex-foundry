# codex-foundry

[![Template Repository](https://img.shields.io/badge/template-repository-0ea5e9?style=flat-square)](https://github.com/jinhyuk9714/codex-foundry/generate)
[![MIT License](https://img.shields.io/badge/license-MIT-16a34a?style=flat-square)](LICENSE)
[![Codex](https://img.shields.io/badge/Codex-CLI%2FApp-111827?style=flat-square)](https://developers.openai.com/codex/)
[![Repo-local](https://img.shields.io/badge/repo--local-self--contained-7c3aed?style=flat-square)](https://developers.openai.com/codex/concepts/customization/)

[English](README.md) | 한국어

Codex 스킬, 워크플로우, bootstrap 설정을 위한 repo-local, self-contained 스타터킷입니다.

`codex-foundry`는 Codex용 기본 골격을 작고 명확하게 제공합니다. 루트 `AGENTS.md`, `.agents/skills` 안의 repo-local 스킬, 선택 적용용 `.codex` 예시, 그리고 기존 저장소에 안전하게 주입할 수 있는 bootstrap 스크립트가 포함되어 있습니다.

## 포함 내용

- 기본 규칙을 담은 짧은 루트 `AGENTS.md`
- repo-local 스킬 8개
  - `feature-design`
  - `implementation-plan`
  - `tdd-implement`
  - `systematic-debug`
  - `request-code-review`
  - `verification-gate`
  - `finish-branch`
  - `codex-setup-check`
- `.codex/config.example.toml`, `.codex/mcp/README.md` 예시
- 기존 저장소에 기본값으로 덮어쓰기 없이 적용하는 bootstrap 스크립트

## 시작하기

### 템플릿으로 새 프로젝트 시작

1. [codex-foundry](https://github.com/jinhyuk9714/codex-foundry)를 엽니다.
2. `Use this template`를 클릭합니다.
3. 새 저장소를 만듭니다.
4. 로컬로 클론합니다.

```bash
git clone <새-레포-주소>
cd <새-레포-이름>
```

5. Codex CLI 또는 Codex 앱에서 저장소를 엽니다.
6. 먼저 아래를 실행합니다.

```text
$codex-setup-check
```

7. 기본 기능 개발 흐름으로 시작합니다.

```text
$feature-design
$implementation-plan
$tdd-implement
$request-code-review
$verification-gate
$finish-branch
```

### 기존 저장소에 codex-foundry 적용

`codex-foundry`를 로컬 어딘가에 받아 둔 뒤, 기존 저장소에서 bootstrap 스크립트를 실행하면 됩니다.

1. 기존 저장소 루트로 이동합니다.
2. 먼저 dry-run으로 어떤 파일이 들어오는지 확인합니다.

```bash
bash /path/to/codex-foundry/scripts/bootstrap.sh --source /path/to/codex-foundry --target . --dry-run
```

3. 확인이 끝나면 실제로 적용합니다.

```bash
bash /path/to/codex-foundry/scripts/bootstrap.sh --source /path/to/codex-foundry --target .
```

4. Codex에서 저장소를 열고 아래를 실행합니다.

```text
$codex-setup-check
```

PowerShell도 지원합니다.

```powershell
pwsh -File C:\path\to\codex-foundry\scripts\bootstrap.ps1 -Source C:\path\to\codex-foundry -Target . -DryRun
pwsh -File C:\path\to\codex-foundry\scripts\bootstrap.ps1 -Source C:\path\to\codex-foundry -Target .
```

## 기본 워크플로우

| 목적 | Codex 흐름 |
| --- | --- |
| 새 기능 개발 | `feature-design` -> `implementation-plan` -> `tdd-implement` -> `request-code-review` -> `verification-gate` |
| 버그 수정 | `systematic-debug` -> `tdd-implement` -> `request-code-review` -> `verification-gate` |
| 작업 마무리 | `finish-branch` |
| 세션 점검 | `codex-setup-check` |

## Claude Forge 방식과의 대응

이 프로젝트는 슬래시 커맨드를 그대로 재현하지 않습니다. 대신 같은 의도를 Codex 스킬로 옮깁니다.

| Claude 스타일 습관 | Codex 방식 |
| --- | --- |
| `/plan` | `$feature-design` 후 `$implementation-plan` |
| `/tdd` | `$tdd-implement` |
| `/code-review` | `$request-code-review` |
| `/handoff-verify` | `$verification-gate` |
| `/explore bug` | `$systematic-debug` |
| `/wrap-up` | `$finish-branch` |
| `/doctor` | `$codex-setup-check` |

## 저장소 구조

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

## 검증

준비 상태를 확인하려면 아래 명령을 실행합니다.

```bash
bash tests/validate_repo.sh
bash tests/bootstrap_safety.sh
```

## 문서

- [First Steps](docs/FIRST-STEPS.md)
- [Workflows](docs/WORKFLOWS.md)
- [Customization](docs/CUSTOMIZATION.md)
