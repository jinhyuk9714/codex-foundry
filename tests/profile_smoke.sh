#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOOTSTRAP="${ROOT_DIR}/scripts/bootstrap.sh"
DOCTOR="${ROOT_DIR}/scripts/codex-doctor.sh"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

run_doctor() {
  local cwd="$1"
  local output_file="$2"
  (
    cd "${cwd}"
    /bin/bash scripts/codex-doctor.sh
  ) > "${output_file}" 2>&1
}

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

profiles=(
  "nextjs-app-router"
  "node-api"
  "python-service"
)

for profile in "${profiles[@]}"; do
  target_dir="${TMP_DIR}/${profile}"
  log_file="${TMP_DIR}/${profile}.log"
  "${BOOTSTRAP}" --source "${ROOT_DIR}" --target "${target_dir}" --profile "${profile}" > /dev/null
  [[ -f "${target_dir}/docs/STACK-PROFILE.md" ]] || fail "${profile} bootstrap should create STACK-PROFILE.md"
  [[ -f "${target_dir}/docs/STACK-PROMPT-PLAYBOOKS.md" ]] || fail "${profile} bootstrap should create STACK-PROMPT-PLAYBOOKS.md"
  grep -q "Profile ID: ${profile}" "${target_dir}/docs/STACK-PROFILE.md" || fail "${profile} overlay should declare the correct profile id"
  if ! run_doctor "${target_dir}" "${log_file}"; then
    fail "doctor should succeed on ${profile} overlay"
  fi
  grep -q "\\[PASS\\] Stack profile overlay is present:" "${log_file}" || fail "doctor should recognize the stack overlay for ${profile}"
done

invalid_log="${TMP_DIR}/invalid.log"
if "${BOOTSTRAP}" --source "${ROOT_DIR}" --target "${TMP_DIR}/invalid" --profile "bad-profile" > "${invalid_log}" 2>&1; then
  fail "bootstrap should reject unknown profiles"
fi
grep -q "Unknown profile:" "${invalid_log}" || fail "bootstrap should explain unknown profiles"

plain_target="${TMP_DIR}/plain"
"${BOOTSTRAP}" --source "${ROOT_DIR}" --target "${plain_target}" > /dev/null
[[ ! -e "${plain_target}/docs/STACK-PROFILE.md" ]] || fail "bootstrap without a profile should not inject STACK-PROFILE.md"
[[ ! -e "${plain_target}/docs/STACK-PROMPT-PLAYBOOKS.md" ]] || fail "bootstrap without a profile should not inject STACK-PROMPT-PLAYBOOKS.md"

echo "profile_smoke.sh: OK"
