# codex-foundry

`codex-foundry`는 Codex가 저장소마다 같은 규칙과 작업 흐름으로 일하도록 돕는 **repo-local, self-contained 스타터킷**입니다. 실행 앱이 아니라 GitHub 템플릿과 bootstrap 스크립트 묶음이며, `AGENTS.md`, repo-local skills, `.codex` 예시, stack profile, 검증 스크립트를 저장소 안에 함께 배치합니다.

한국어 README입니다. 영문 문서는 `README.en.md`를 참고하세요.

## 문제의식

Codex 협업에서 가장 자주 흐트러지는 부분은 "이 저장소에서는 어떻게 설계하고, 구현하고, 검증하고, 마무리할지"입니다. `codex-foundry`는 그 규칙을 외부 기억에 맡기지 않고 레포 안에 둡니다. 새 프로젝트는 템플릿으로 시작하고, 기존 프로젝트에는 bootstrap으로 안전하게 주입할 수 있습니다.

## 포함 내용

- `AGENTS.md`: 저장소 기본 작업 규칙
- `.agents/skills/`: 반복 가능한 작업 흐름을 담은 8개 repo-local skill
- `.codex/`: 최소 config 예시와 선택형 multi-agent 레이어
- `profiles/`: Next.js App Router, Node API, Python service용 stack profile
- `scripts/bootstrap.sh`, `scripts/bootstrap.ps1`: 기존 저장소에 기본 파일 주입
- `scripts/codex-doctor.sh`, `scripts/codex-doctor.ps1`: setup smoke check
- `scripts/upgrade.sh`, `scripts/upgrade.ps1`: 기존 foundry 파일 업데이트
- `docs/`: first steps, workflow, prompt playbook, customization, releasing 문서

## 기본 워크플로우

- 새 기능: `feature-design` -> `implementation-plan` -> `tdd-implement` -> `request-code-review` -> `verification-gate`
- 버그 수정: `systematic-debug` -> `tdd-implement` -> `request-code-review` -> `verification-gate`
- 검증까지 끝난 작업 정리: `finish-branch`
- 세션 시작이나 bootstrap 직후 점검: `codex-setup-check`

복붙 가능한 프롬프트 예시는 `docs/PROMPT-PLAYBOOKS.ko.md`에 정리되어 있습니다.

## 새 프로젝트로 시작

1. GitHub에서 `Use this template`으로 새 저장소를 만듭니다.
2. 만든 저장소를 클론합니다.
3. Codex CLI 또는 Codex 앱에서 엽니다.
4. 첫 점검으로 아래 skill을 실행합니다.

```text
$codex-setup-check
```

5. 실제 setup 진단을 실행합니다.

```bash
bash scripts/codex-doctor.sh
```

그다음 작업 흐름에 맞춰 아래 skill들을 사용합니다.

```text
$feature-design
$implementation-plan
$tdd-implement
```

## 기존 저장소에 붙이기

먼저 dry-run으로 변경 범위를 확인합니다.

```bash
bash /path/to/codex-foundry/scripts/bootstrap.sh --source /path/to/codex-foundry --target . --dry-run
```

괜찮으면 실제로 적용합니다.

```bash
bash /path/to/codex-foundry/scripts/bootstrap.sh --source /path/to/codex-foundry --target .
```

스택 overlay가 필요하면 `--profile`을 붙입니다.

```bash
bash /path/to/codex-foundry/scripts/bootstrap.sh --source /path/to/codex-foundry --target . --profile nextjs-app-router
```

PowerShell 경로도 제공합니다.

```powershell
pwsh -File C:\path\to\codex-foundry\scripts\bootstrap.ps1 -Source C:\path\to\codex-foundry -Target . -DryRun
pwsh -File C:\path\to\codex-foundry\scripts\bootstrap.ps1 -Source C:\path\to\codex-foundry -Target .
pwsh -File scripts\codex-doctor.ps1
```

이미 `codex-foundry`가 들어 있는 저장소를 갱신할 때는 bootstrap 대신 `docs/UPGRADING.md`와 upgrade 스크립트를 사용합니다.

## 기술과 구조

이 저장소는 별도 앱 런타임 의존성을 두지 않는 shell/PowerShell 중심 템플릿입니다.

```text
AGENTS.md
.agents/skills/                 # repo-local skill 8개
.codex/                         # config와 agent 예시
profiles/                       # stack별 overlay 문서
scripts/                        # bootstrap, doctor, upgrade, release helper
tests/                          # shell smoke test
docs/                           # 사용법과 운영 문서
VERSION
CHANGELOG.md
```

현재 버전은 `VERSION` 파일의 `0.8.0`입니다.

## 검증

```bash
bash tests/bootstrap_safety.sh
bash tests/doctor_smoke.sh
bash tests/profile_smoke.sh
bash tests/release_smoke.sh
bash tests/upgrade_smoke.sh
bash tests/validate_repo.sh
```

## 문서

- `docs/FIRST-STEPS.md`
- `docs/PROMPT-PLAYBOOKS.ko.md`
- `docs/STACK-PROFILES.md`
- `docs/WORKFLOWS.md`
- `docs/CUSTOMIZATION.md`
- `docs/UPGRADING.md`
- `docs/RELEASING.md`
- `docs/ADVANCED-CODEX-POWER.md`
- `docs/SETUP-DOCTOR.md`

## 라이선스

MIT
