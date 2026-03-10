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
grep -q "docs/PROMPT-PLAYBOOKS.md" "${DRY_RUN_LOG}" || fail "dry-run output should mention Prompt Playbooks"
grep -q "docs/PROMPT-PLAYBOOKS.ko.md" "${DRY_RUN_LOG}" || fail "dry-run output should mention Korean Prompt Playbooks"
grep -q "docs/STACK-PROFILES.md" "${DRY_RUN_LOG}" || fail "dry-run output should mention Stack Profiles"
grep -q "profiles/nextjs-app-router/docs/STACK-PROFILE.md" "${DRY_RUN_LOG}" || fail "dry-run output should mention the nextjs profile sources"
grep -q "scripts/codex-doctor.sh" "${DRY_RUN_LOG}" || fail "dry-run output should mention shell doctor"
grep -q "scripts/codex-doctor.ps1" "${DRY_RUN_LOG}" || fail "dry-run output should mention PowerShell doctor"
grep -q "scripts/upgrade.sh" "${DRY_RUN_LOG}" || fail "dry-run output should mention shell upgrade"
grep -q "scripts/upgrade.ps1" "${DRY_RUN_LOG}" || fail "dry-run output should mention PowerShell upgrade"
grep -q "scripts/manifest-tools.sh" "${DRY_RUN_LOG}" || fail "dry-run output should mention manifest tools"
grep -q "scripts/managed-files.txt" "${DRY_RUN_LOG}" || fail "dry-run output should mention managed file list"
grep -q "scripts/bootstrap-files.txt" "${DRY_RUN_LOG}" || fail "dry-run output should mention bootstrap file list"
grep -q "docs/SETUP-DOCTOR.md" "${DRY_RUN_LOG}" || fail "dry-run output should mention setup doctor docs"
grep -q ".codex-foundry/manifest.toml" "${DRY_RUN_LOG}" || fail "dry-run output should mention the managed manifest"

PROFILE_DRY_RUN_LOG="${TMP_DIR}/profile-dry-run.log"
"${BOOTSTRAP}" --source "${ROOT_DIR}" --target "${TARGET_DIR}" --profile "nextjs-app-router" --dry-run > "${PROFILE_DRY_RUN_LOG}"
grep -q "docs/STACK-PROFILE.md" "${PROFILE_DRY_RUN_LOG}" || fail "profile dry-run output should mention STACK-PROFILE.md"
grep -q "docs/STACK-PROMPT-PLAYBOOKS.md" "${PROFILE_DRY_RUN_LOG}" || fail "profile dry-run output should mention STACK-PROMPT-PLAYBOOKS.md"
grep -q ".codex-foundry/manifest.toml" "${PROFILE_DRY_RUN_LOG}" || fail "profile dry-run should mention the managed manifest"

"${BOOTSTRAP}" --source "${ROOT_DIR}" --target "${TARGET_DIR}"

[[ -f "${TARGET_DIR}/AGENTS.md" ]] || fail "bootstrap should copy AGENTS.md"
[[ -f "${TARGET_DIR}/.agents/skills/feature-design/SKILL.md" ]] || fail "bootstrap should copy skills"
[[ -f "${TARGET_DIR}/.codex/config.example.toml" ]] || fail "bootstrap should copy the config example"
[[ -f "${TARGET_DIR}/.codex/config.multi-agent.example.toml" ]] || fail "bootstrap should copy the multi-agent config example"
[[ -f "${TARGET_DIR}/.codex/agents/reviewer.toml" ]] || fail "bootstrap should copy advanced agent configs"
[[ -f "${TARGET_DIR}/docs/ADVANCED-CODEX-POWER.md" ]] || fail "bootstrap should copy the advanced docs"
[[ -f "${TARGET_DIR}/docs/PROMPT-PLAYBOOKS.md" ]] || fail "bootstrap should copy Prompt Playbooks"
[[ -f "${TARGET_DIR}/docs/PROMPT-PLAYBOOKS.ko.md" ]] || fail "bootstrap should copy Korean Prompt Playbooks"
[[ -f "${TARGET_DIR}/docs/STACK-PROFILES.md" ]] || fail "bootstrap should copy Stack Profiles"
[[ -f "${TARGET_DIR}/profiles/nextjs-app-router/docs/STACK-PROFILE.md" ]] || fail "bootstrap should copy the profile sources"
[[ -f "${TARGET_DIR}/scripts/codex-doctor.sh" ]] || fail "bootstrap should copy the shell doctor"
[[ -f "${TARGET_DIR}/scripts/codex-doctor.ps1" ]] || fail "bootstrap should copy the PowerShell doctor"
[[ -f "${TARGET_DIR}/scripts/upgrade.sh" ]] || fail "bootstrap should copy the shell upgrade script"
[[ -f "${TARGET_DIR}/scripts/upgrade.ps1" ]] || fail "bootstrap should copy the PowerShell upgrade script"
[[ -f "${TARGET_DIR}/scripts/manifest-tools.sh" ]] || fail "bootstrap should copy manifest tools"
[[ -f "${TARGET_DIR}/scripts/managed-files.txt" ]] || fail "bootstrap should copy the managed file list"
[[ -f "${TARGET_DIR}/scripts/bootstrap-files.txt" ]] || fail "bootstrap should copy the bootstrap file list"
[[ -f "${TARGET_DIR}/docs/SETUP-DOCTOR.md" ]] || fail "bootstrap should copy the setup doctor docs"
[[ -f "${TARGET_DIR}/.codex-foundry/manifest.toml" ]] || fail "bootstrap should generate the managed manifest"
grep -q 'kit = "codex-foundry"' "${TARGET_DIR}/.codex-foundry/manifest.toml" || fail "bootstrap manifest should declare the kit"
grep -q '^active_profile = ""$' "${TARGET_DIR}/.codex-foundry/manifest.toml" || fail "bootstrap manifest should default to no active profile"
grep -q 'path = "AGENTS.md"' "${TARGET_DIR}/.codex-foundry/manifest.toml" || fail "bootstrap manifest should track AGENTS.md"
grep -q 'path = "scripts/upgrade.sh"' "${TARGET_DIR}/.codex-foundry/manifest.toml" || fail "bootstrap manifest should track upgrade.sh"

PROFILE_TARGET_DIR="${TMP_DIR}/profile-target"
"${BOOTSTRAP}" --source "${ROOT_DIR}" --target "${PROFILE_TARGET_DIR}" --profile "nextjs-app-router"
[[ -f "${PROFILE_TARGET_DIR}/docs/STACK-PROFILE.md" ]] || fail "profile bootstrap should copy STACK-PROFILE.md"
[[ -f "${PROFILE_TARGET_DIR}/docs/STACK-PROMPT-PLAYBOOKS.md" ]] || fail "profile bootstrap should copy STACK-PROMPT-PLAYBOOKS.md"
grep -q "Profile ID: nextjs-app-router" "${PROFILE_TARGET_DIR}/docs/STACK-PROFILE.md" || fail "profile bootstrap should copy the selected profile overlay"
[[ -f "${PROFILE_TARGET_DIR}/.codex-foundry/manifest.toml" ]] || fail "profile bootstrap should generate a manifest"
grep -q '^active_profile = "nextjs-app-router"$' "${PROFILE_TARGET_DIR}/.codex-foundry/manifest.toml" || fail "profile bootstrap manifest should track the active profile"
grep -q 'path = "docs/STACK-PROFILE.md"' "${PROFILE_TARGET_DIR}/.codex-foundry/manifest.toml" || fail "profile bootstrap manifest should track STACK-PROFILE.md"
grep -q 'path = "docs/STACK-PROMPT-PLAYBOOKS.md"' "${PROFILE_TARGET_DIR}/.codex-foundry/manifest.toml" || fail "profile bootstrap manifest should track STACK-PROMPT-PLAYBOOKS.md"

echo "user-owned" > "${TARGET_DIR}/AGENTS.md"
if "${BOOTSTRAP}" --source "${ROOT_DIR}" --target "${TARGET_DIR}" > "${TMP_DIR}/overwrite.log" 2>&1; then
  fail "bootstrap should refuse to overwrite existing files without --force"
fi

grep -q "already exists" "${TMP_DIR}/overwrite.log" || fail "overwrite refusal should explain the conflict"
grep -q "user-owned" "${TARGET_DIR}/AGENTS.md" || fail "bootstrap should not overwrite existing files by default"

echo "bootstrap_safety.sh: OK"
