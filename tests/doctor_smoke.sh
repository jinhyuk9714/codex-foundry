#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOOTSTRAP="${ROOT_DIR}/scripts/bootstrap.sh"
DOCTOR="${ROOT_DIR}/scripts/codex-doctor.sh"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

make_path_without_tools() {
  local bin_dir="$1"
  mkdir -p "${bin_dir}"
  ln -s "$(command -v grep)" "${bin_dir}/grep"
}

run_doctor() {
  local cwd="$1"
  local output_file="$2"
  shift 2
  (
    cd "${cwd}"
    "$@" /bin/bash scripts/codex-doctor.sh
  ) > "${output_file}" 2>&1
}

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

FULL_LOG="${TMP_DIR}/full.log"
if ! run_doctor "${ROOT_DIR}" "${FULL_LOG}"; then
  fail "doctor should succeed on the complete template repo"
fi
grep -q "Summary: " "${FULL_LOG}" || fail "doctor should print a summary"
grep -q "\\[PASS\\]" "${FULL_LOG}" || fail "doctor should report passing checks on the template repo"
! grep -q "\\[FAIL\\]" "${FULL_LOG}" || fail "doctor should not report failures on the complete template repo"
grep -q "\\[PASS\\] Managed manifest is present and well-formed." "${FULL_LOG}" || fail "doctor should validate the managed manifest on the template repo"

MISSING_SKILL_DIR="${TMP_DIR}/missing-skill"
"${BOOTSTRAP}" --source "${ROOT_DIR}" --target "${MISSING_SKILL_DIR}" > /dev/null
rm -rf "${MISSING_SKILL_DIR}/.agents/skills/feature-design"
MISSING_SKILL_LOG="${TMP_DIR}/missing-skill.log"
if run_doctor "${MISSING_SKILL_DIR}" "${MISSING_SKILL_LOG}"; then
  fail "doctor should fail when a required skill is missing"
fi
grep -q "\\[FAIL\\] Missing repo-local skills:" "${MISSING_SKILL_LOG}" || fail "doctor should explain missing required skills"

CONFIG_WARN_DIR="${TMP_DIR}/config-warn"
"${BOOTSTRAP}" --source "${ROOT_DIR}" --target "${CONFIG_WARN_DIR}" > /dev/null
cp "${CONFIG_WARN_DIR}/.codex/config.example.toml" "${CONFIG_WARN_DIR}/.codex/config.toml"
CONFIG_WARN_LOG="${TMP_DIR}/config-warn.log"
if ! run_doctor "${CONFIG_WARN_DIR}" "${CONFIG_WARN_LOG}"; then
  fail "doctor should not fail for a trusted-project warning"
fi
grep -q "\\[WARN\\] Project-scoped .codex/config.toml only loads in trusted projects." "${CONFIG_WARN_LOG}" || fail "doctor should warn about trusted project requirements"
grep -q "/debug-config" "${CONFIG_WARN_LOG}" || fail "doctor should recommend /debug-config for project config issues"

MISSING_ROLE_DIR="${TMP_DIR}/missing-role"
"${BOOTSTRAP}" --source "${ROOT_DIR}" --target "${MISSING_ROLE_DIR}" > /dev/null
cp "${MISSING_ROLE_DIR}/.codex/config.multi-agent.example.toml" "${MISSING_ROLE_DIR}/.codex/config.toml"
rm -f "${MISSING_ROLE_DIR}/.codex/agents/reviewer.toml"
MISSING_ROLE_LOG="${TMP_DIR}/missing-role.log"
if run_doctor "${MISSING_ROLE_DIR}" "${MISSING_ROLE_LOG}"; then
  fail "doctor should fail when the project config references a missing role file"
fi
grep -q "\\[FAIL\\] .codex/config.toml references missing role files:" "${MISSING_ROLE_LOG}" || fail "doctor should report missing multi-agent role files"

LEGACY_DIR="${TMP_DIR}/legacy"
"${BOOTSTRAP}" --source "${ROOT_DIR}" --target "${LEGACY_DIR}" > /dev/null
rm -f "${LEGACY_DIR}/.codex-foundry/manifest.toml"
LEGACY_LOG="${TMP_DIR}/legacy.log"
if ! run_doctor "${LEGACY_DIR}" "${LEGACY_LOG}"; then
  fail "doctor should warn, not fail, when a legacy repo is missing the manifest"
fi
grep -q "\\[WARN\\] Managed manifest is missing. This looks like a legacy repo." "${LEGACY_LOG}" || fail "doctor should warn when the managed manifest is missing"
grep -q "scripts/upgrade.sh --source" "${LEGACY_LOG}" || fail "doctor should recommend the adopt upgrade path for legacy repos"

NO_NPX_DIR="${TMP_DIR}/no-npx"
"${BOOTSTRAP}" --source "${ROOT_DIR}" --target "${NO_NPX_DIR}" > /dev/null
cp "${NO_NPX_DIR}/.codex/config.example.toml" "${NO_NPX_DIR}/.codex/config.toml"
NO_NPX_PATH="${TMP_DIR}/bin-no-npx"
make_path_without_tools "${NO_NPX_PATH}"
NO_NPX_LOG="${TMP_DIR}/no-npx.log"
if ! PATH="${NO_NPX_PATH}" run_doctor "${NO_NPX_DIR}" "${NO_NPX_LOG}"; then
  fail "doctor should not hard fail when npx is missing"
fi
grep -q "\\[WARN\\] context7 is configured in .codex/config.toml but npx is not available." "${NO_NPX_LOG}" || fail "doctor should warn when context7 is configured without npx"

NO_CODEX_DIR="${TMP_DIR}/no-codex"
"${BOOTSTRAP}" --source "${ROOT_DIR}" --target "${NO_CODEX_DIR}" > /dev/null
NO_CODEX_PATH="${TMP_DIR}/bin-no-codex"
make_path_without_tools "${NO_CODEX_PATH}"
NO_CODEX_LOG="${TMP_DIR}/no-codex.log"
if ! PATH="${NO_CODEX_PATH}" run_doctor "${NO_CODEX_DIR}" "${NO_CODEX_LOG}"; then
  fail "doctor should not hard fail when codex is missing"
fi
grep -q "\\[WARN\\] codex is not on PATH." "${NO_CODEX_LOG}" || fail "doctor should warn when codex is missing"
grep -q "Summary: " "${NO_CODEX_LOG}" || fail "doctor should still print a summary when codex is missing"

echo "doctor_smoke.sh: OK"
