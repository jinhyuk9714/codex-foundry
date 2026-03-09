# Prompt Playbooks

이 문서는 문서를 해석해서 직접 프롬프트를 만들기보다, 바로 복붙해서 시작하고 싶을 때 쓰는 플레이북입니다. 아래 블록은 한 번에 하나씩 붙여 넣고, Codex의 응답을 받은 다음 다음 블록으로 넘어가면 됩니다.

이미 [Stack Profiles](STACK-PROFILES.md)에서 stack overlay를 적용했다면, 같은 흐름을 쓰되 `docs/STACK-PROFILE.md`를 함께 참고하라고 Codex에 알려주면 됩니다.

## Bootstrap Playbook

템플릿으로 새 레포를 만들었거나, 기존 저장소에 `codex-foundry`를 주입한 직후에 쓰는 흐름입니다. 기능 개발이나 버그 수정보다 먼저, repo-local 설정이 제대로 들어왔는지 확인하는 것이 목적입니다.

먼저 setup 진입점을 실행합니다.

```text
$codex-setup-check
This repository is using codex-foundry. Confirm the repo-local setup and tell me what to verify next.
```

그다음 실행형 doctor를 돌립니다.

```bash
bash scripts/codex-doctor.sh
```

PowerShell도 가능합니다.

```powershell
pwsh -File scripts/codex-doctor.ps1
```

기대되는 Codex 반응:
- 필수 repo-local 파일과 스킬이 있는지 확인합니다.
- `/status`, `/debug-config`, `/mcp` 같은 다음 점검 명령을 짚어줍니다.
- 이제 `Feature Playbook`으로 갈지 `Bugfix Playbook`으로 갈지 알려줍니다.

다음 단계:
- 레포가 준비됐으면 [Feature Playbook](#feature-playbook)이나 [Bugfix Playbook](#bugfix-playbook)으로 넘어갑니다.
- doctor가 config나 MCP 경고를 내면 먼저 그것부터 정리하고 다시 실행합니다.

흔한 실수:
- `$codex-setup-check` 없이 바로 기능 구현을 시키는 것
- doctor 결과를 보기 전에 `.codex/config.toml`를 감으로 고치는 것
- `FAIL`이 나왔는데도 그냥 다음 단계로 넘어가는 것

## Feature Playbook

새 기능을 추가할 때 쓰는 기본 흐름입니다. `feature-design`, `implementation-plan`, `tdd-implement` 순서를 지키게 만드는 것이 목적입니다. 아래 블록을 순서대로 사용합니다.

먼저 설계부터 요청합니다.

```text
$feature-design
I want to add <feature>. Constraints: <key constraints>. Success means <user-visible outcome>.
```

설계가 승인되면 구현 계획으로 넘깁니다.

```text
$implementation-plan
Turn the approved design for <feature> into a decision-complete implementation plan.
```

그다음 구현을 시작합니다.

```text
$tdd-implement
Implement the approved plan for <feature> with a strict red-green-refactor flow.
```

마지막에는 리뷰와 검증으로 닫습니다.

```text
$request-code-review
Review the completed <feature> work for bugs, regressions, and missing coverage.
```

```text
$verification-gate
Run the commands that prove <feature> is complete and show the results.
```

```text
$finish-branch
Summarize the finished <feature> change, remaining risks, and the next integration step.
```

기대되는 Codex 반응:
- 기능 아이디어를 먼저 승인 가능한 설계로 바꿉니다.
- 구현 전에 결정이 끝난 계획으로 정리합니다.
- 테스트 기반 구현, 리뷰, 검증 명령 실행까지 순서대로 진행합니다.

다음 단계:
- 설계 범위가 너무 넓게 나오면 `<feature>` 설명을 더 좁힙니다.
- 흐름 전체에서 같은 `<feature>` 표현을 유지해 문맥이 흔들리지 않게 합니다.

흔한 실수:
- `feature-design` 없이 “그냥 구현해줘”로 시작하는 것
- 서로 다른 기능을 한 요청에 몰아넣는 것
- 코드가 얼핏 맞아 보여서 `request-code-review`나 `verification-gate`를 생략하는 것

## Bugfix Playbook

버그가 있거나 동작이 불명확할 때 쓰는 흐름입니다. 핵심은 Codex가 `systematic-debug`로 문제를 먼저 재현하게 만드는 것입니다.

먼저 증상과 재현 정보를 줍니다.

```text
$systematic-debug
The bug is: <symptom>. Expected behavior: <expected result>. How to reproduce: <steps or failing command>.
```

문제가 재현되면 수정 흐름으로 넘어갑니다.

```text
$tdd-implement
Add the regression test for <bug>, watch it fail for the right reason, then implement the fix.
```

그다음 리뷰와 검증을 실행합니다.

```text
$request-code-review
Review the <bug> fix for root-cause coverage, regressions, and missing tests.
```

```text
$verification-gate
Run the commands that prove the <bug> fix works and show the results.
```

```text
$finish-branch
Summarize the <bug> fix, remaining risks, and the next integration step.
```

기대되는 Codex 반응:
- 수정 전에 버그를 먼저 재현합니다.
- 프로덕션 코드보다 회귀 테스트를 먼저 추가합니다.
- 버그가 고쳐졌다는 것을 보여주는 검증 명령을 다시 실행합니다.

다음 단계:
- 재현 정보가 약하면 실패 명령, 스택 트레이스, 입력 예시를 더 추가합니다.
- 수정 범위가 커지면 첫 버그 수정과 후속 정리를 나눕니다.

흔한 실수:
- 관찰한 증상 대신 “원인은 이거야”라는 추측부터 주는 것
- 재현 확인 없이 “아마 고쳐졌을 것”이라고 넘어가는 것
- 코드 수정 후 마지막 검증을 생략하는 것
