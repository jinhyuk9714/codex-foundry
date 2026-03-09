# codex-foundry

[![Template Repository](https://img.shields.io/badge/template-repository-0ea5e9?style=flat-square)](https://github.com/jinhyuk9714/codex-foundry/generate)
[![MIT License](https://img.shields.io/badge/license-MIT-16a34a?style=flat-square)](LICENSE)
[![Codex](https://img.shields.io/badge/Codex-CLI%2FApp-111827?style=flat-square)](https://developers.openai.com/codex/)
[![Repo-local](https://img.shields.io/badge/repo--local-self--contained-7c3aed?style=flat-square)](https://developers.openai.com/codex/concepts/customization/)

[English](README.md) | 한국어

Codex 스킬, 워크플로우, bootstrap 설정을 위한 repo-local, self-contained 스타터킷입니다.

`codex-foundry`는 Codex가 레포마다 비슷한 방식으로 일하도록 맞춰 주는 GitHub 템플릿입니다. 핵심은 전부 레포 안에 둡니다. 짧은 `AGENTS.md`, 이름이 고정된 스킬 8개, 선택 적용용 `.codex` 예시, 그리고 기존 코드베이스에 안전하게 넣을 수 있는 bootstrap 스크립트가 그 구성입니다.

## 이 프로젝트는 무엇인가

`codex-foundry`는 실행하는 앱이 아닙니다. Codex가 매번 같은 규칙과 같은 작업 흐름을 보도록 레포에 깔아 두는 시작 레이어입니다.

- `AGENTS.md`가 레포 기본 규칙을 잡습니다.
- `.agents/skills/`가 반복 가능한 작업 흐름을 이름 있는 스킬로 제공합니다.
- `.codex/`는 필요할 때만 켜는 선택형 설정 레이어입니다.
- `scripts/bootstrap.sh`, `scripts/bootstrap.ps1`는 기존 저장소에 기본값으로 덮어쓰기 없이 이 키트를 주입합니다.

## 바로 시작하기

`codex-foundry`를 쓰는 경로는 두 가지입니다.

### 새 프로젝트로 시작

새 저장소의 베이스로 쓸 때는 템플릿 경로가 가장 깔끔합니다.

1. [codex-foundry](https://github.com/jinhyuk9714/codex-foundry)를 엽니다.
2. `Use this template` 버튼으로 새 저장소를 만듭니다.
3. 만든 저장소를 클론합니다.

```bash
git clone <새-레포-주소>
cd <새-레포-이름>
```

4. Codex CLI 또는 Codex 앱에서 엽니다.
5. 첫 점검으로 아래를 실행합니다.

```text
$codex-setup-check
```

6. 이어서 실제 setup 진단을 실행합니다.

```bash
bash scripts/codex-doctor.sh
```

7. 그다음 기본 작업 흐름으로 들어갑니다.

```text
$feature-design
$implementation-plan
$tdd-implement
```

### 기존 저장소에 붙이기

이미 있는 저장소에 넣고 싶다면 bootstrap 스크립트를 쓰면 됩니다.

1. 로컬 어딘가에 `codex-foundry`를 받아 둡니다.
2. 기존 저장소에서 먼저 dry-run으로 확인합니다.

```bash
bash /path/to/codex-foundry/scripts/bootstrap.sh --source /path/to/codex-foundry --target . --dry-run
```

3. 괜찮으면 실제로 적용합니다.

```bash
bash /path/to/codex-foundry/scripts/bootstrap.sh --source /path/to/codex-foundry --target .
```

4. 그 저장소를 Codex에서 열고 아래를 실행합니다.

```text
$codex-setup-check
```

5. 이어서 아래를 실행합니다.

```bash
bash scripts/codex-doctor.sh
```

PowerShell도 지원합니다.

```powershell
pwsh -File C:\path\to\codex-foundry\scripts\bootstrap.ps1 -Source C:\path\to\codex-foundry -Target . -DryRun
pwsh -File C:\path\to\codex-foundry\scripts\bootstrap.ps1 -Source C:\path\to\codex-foundry -Target .
pwsh -File scripts\codex-doctor.ps1
```

## 기본 워크플로우

- 새 기능: `feature-design` -> `implementation-plan` -> `tdd-implement` -> `request-code-review` -> `verification-gate`
- 버그 수정: `systematic-debug` -> `tdd-implement` -> `request-code-review` -> `verification-gate`
- 검증까지 끝난 작업 정리: `finish-branch`
- 세션 시작이나 bootstrap 직후 점검: `codex-setup-check`

## 고급 Codex 기능

기본 키트는 작게 두고, 더 큰 변경이나 문서 검증이 필요할 때만 고급 레이어를 켜는 방식입니다.

- 최소 레이어만 쓰고 싶다면 `.codex/config.example.toml`만 참고하면 됩니다.
- 실험적인 multi-agent 레이어가 필요하면 아래처럼 복사해서 켭니다.

```bash
cp .codex/config.multi-agent.example.toml .codex/config.toml
```

- 이 레이어에는 `explorer`, `reviewer`, `docs_researcher` 역할이 들어 있습니다.
- 자세한 설명과 예시는 [Advanced Codex Power](docs/ADVANCED-CODEX-POWER.md)에 있습니다.

## 포함 내용

- `AGENTS.md`: Codex가 계속 참고할 레포 기본 규칙
- 8개 repo-local 스킬: `feature-design`, `implementation-plan`, `tdd-implement`, `systematic-debug`, `request-code-review`, `verification-gate`, `finish-branch`, `codex-setup-check`
- 최소 `.codex` 예시: `.codex/config.example.toml`, `.codex/mcp/README.md`
- 선택형 multi-agent 레이어: `.codex/config.multi-agent.example.toml`, `.codex/agents/`
- 실행형 doctor 스크립트: `scripts/codex-doctor.sh`, `scripts/codex-doctor.ps1`
- 안전한 주입 스크립트: `scripts/bootstrap.sh`, `scripts/bootstrap.ps1`

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
- [Advanced Codex Power](docs/ADVANCED-CODEX-POWER.md)
- [Setup Doctor](docs/SETUP-DOCTOR.md)
