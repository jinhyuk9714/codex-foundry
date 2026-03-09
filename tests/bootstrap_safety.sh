#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOOTSTRAP="${ROOT_DIR}/scripts/bootstrap.sh"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

DRY_RUN_LOG="${TMP_DIR}/dry-run.log"
TARGET_DIR="${TMP_DIR}/target"
mkdir -p "${TARGET_DIR}"

"${BOOTSTRAP}" --source "${ROOT_DIR}" --target "${TARGET_DIR}" --dry-run > "${DRY_RUN_LOG}"

[[ ! -e "${TARGET_DIR}/AGENTS.md" ]] || fail "dry-run should not create files"
grep -q "AGENTS.md" "${DRY_RUN_LOG}" || fail "dry-run output should mention AGENTS.md"
grep -q ".agents/skills/feature-design" "${DRY_RUN_LOG}" || fail "dry-run output should mention skill directories"
grep -q ".codex/config.multi-agent.example.toml" "${DRY_RUN_LOG}" || fail "dry-run output should mention advanced config"
grep -q ".codex/agents/reviewer.toml" "${DRY_RUN_LOG}" || fail "dry-run output should mention advanced agent configs"
grep -q "docs/ADVANCED-CODEX-POWER.md" "${DRY_RUN_LOG}" || fail "dry-run output should mention advanced docs"
grep -q "scripts/codex-doctor.sh" "${DRY_RUN_LOG}" || fail "dry-run output should mention shell doctor"
grep -q "scripts/codex-doctor.ps1" "${DRY_RUN_LOG}" || fail "dry-run output should mention PowerShell doctor"
grep -q "docs/SETUP-DOCTOR.md" "${DRY_RUN_LOG}" || fail "dry-run output should mention setup doctor docs"

"${BOOTSTRAP}" --source "${ROOT_DIR}" --target "${TARGET_DIR}"

[[ -f "${TARGET_DIR}/AGENTS.md" ]] || fail "bootstrap should copy AGENTS.md"
[[ -f "${TARGET_DIR}/.agents/skills/feature-design/SKILL.md" ]] || fail "bootstrap should copy skills"
[[ -f "${TARGET_DIR}/.codex/config.example.toml" ]] || fail "bootstrap should copy the config example"
[[ -f "${TARGET_DIR}/.codex/config.multi-agent.example.toml" ]] || fail "bootstrap should copy the multi-agent config example"
[[ -f "${TARGET_DIR}/.codex/agents/reviewer.toml" ]] || fail "bootstrap should copy advanced agent configs"
[[ -f "${TARGET_DIR}/docs/ADVANCED-CODEX-POWER.md" ]] || fail "bootstrap should copy the advanced docs"
[[ -f "${TARGET_DIR}/scripts/codex-doctor.sh" ]] || fail "bootstrap should copy the shell doctor"
[[ -f "${TARGET_DIR}/scripts/codex-doctor.ps1" ]] || fail "bootstrap should copy the PowerShell doctor"
[[ -f "${TARGET_DIR}/docs/SETUP-DOCTOR.md" ]] || fail "bootstrap should copy the setup doctor docs"

echo "user-owned" > "${TARGET_DIR}/AGENTS.md"
if "${BOOTSTRAP}" --source "${ROOT_DIR}" --target "${TARGET_DIR}" > "${TMP_DIR}/overwrite.log" 2>&1; then
  fail "bootstrap should refuse to overwrite existing files without --force"
fi

grep -q "already exists" "${TMP_DIR}/overwrite.log" || fail "overwrite refusal should explain the conflict"
grep -q "user-owned" "${TARGET_DIR}/AGENTS.md" || fail "bootstrap should not overwrite existing files by default"

echo "bootstrap_safety.sh: OK"
