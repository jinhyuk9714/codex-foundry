#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BOOTSTRAP="${ROOT_DIR}/scripts/bootstrap.sh"
UPGRADE="${ROOT_DIR}/scripts/upgrade.sh"
DOCTOR="${ROOT_DIR}/scripts/codex-doctor.sh"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

copy_repo_snapshot() {
  local dest="$1"
  mkdir -p "${dest}"
  (
    cd "${ROOT_DIR}"
    tar -cf - \
      --exclude=.git \
      --exclude=.worktrees \
      --exclude=worktrees \
      --exclude=tmp \
      .
  ) | (
    cd "${dest}"
    tar -xf -
  )
}

assert_contains() {
  local file="$1"
  local pattern="$2"
  grep -q -- "${pattern}" "${file}" || fail "expected ${file} to contain ${pattern}"
}

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

SOURCE_COMMIT="$(git -C "${ROOT_DIR}" rev-parse HEAD)"

BOOTSTRAP_TARGET="${TMP_DIR}/bootstrap-target"
"${BOOTSTRAP}" --source "${ROOT_DIR}" --target "${BOOTSTRAP_TARGET}" > /dev/null
[[ -f "${BOOTSTRAP_TARGET}/.codex-foundry/manifest.toml" ]] || fail "bootstrap should create a manifest"
assert_contains "${BOOTSTRAP_TARGET}/.codex-foundry/manifest.toml" 'kit = "codex-foundry"'
assert_contains "${BOOTSTRAP_TARGET}/.codex-foundry/manifest.toml" 'manifest_version = 1'
assert_contains "${BOOTSTRAP_TARGET}/.codex-foundry/manifest.toml" "source_commit = \"${SOURCE_COMMIT}\""
assert_contains "${BOOTSTRAP_TARGET}/.codex-foundry/manifest.toml" 'path = "AGENTS.md"'

OLD_SOURCE="${TMP_DIR}/old-source"
copy_repo_snapshot "${OLD_SOURCE}"
printf '\nLegacy source marker.\n' >> "${OLD_SOURCE}/docs/WORKFLOWS.md"
printf '\nLegacy nextjs marker.\n' >> "${OLD_SOURCE}/profiles/nextjs-app-router/docs/STACK-PROFILE.md"

CLEAN_TARGET="${TMP_DIR}/clean-target"
"${BOOTSTRAP}" --source "${OLD_SOURCE}" --target "${CLEAN_TARGET}" > /dev/null
grep -q "Legacy source marker." "${CLEAN_TARGET}/docs/WORKFLOWS.md" || fail "clean target should start from the old source snapshot"
"${UPGRADE}" --source "${ROOT_DIR}" --target "${CLEAN_TARGET}" > "${TMP_DIR}/clean-upgrade.log" 2>&1 || fail "upgrade should succeed for an unmodified managed repo"
! grep -q "Legacy source marker." "${CLEAN_TARGET}/docs/WORKFLOWS.md" || fail "upgrade should refresh managed files from the new source"
assert_contains "${CLEAN_TARGET}/.codex-foundry/manifest.toml" "source_commit = \"${SOURCE_COMMIT}\""

CONFLICT_TARGET="${TMP_DIR}/conflict-target"
"${BOOTSTRAP}" --source "${OLD_SOURCE}" --target "${CONFLICT_TARGET}" > /dev/null
printf '\nLocal user edit.\n' >> "${CONFLICT_TARGET}/docs/WORKFLOWS.md"
if "${UPGRADE}" --source "${ROOT_DIR}" --target "${CONFLICT_TARGET}" > "${TMP_DIR}/conflict.log" 2>&1; then
  fail "upgrade should fail when a managed file has local edits"
fi
assert_contains "${TMP_DIR}/conflict.log" "docs/WORKFLOWS.md"
grep -q "Local user edit." "${CONFLICT_TARGET}/docs/WORKFLOWS.md" || fail "upgrade must not overwrite conflicting user edits"

LEGACY_TARGET="${TMP_DIR}/legacy-target"
"${BOOTSTRAP}" --source "${OLD_SOURCE}" --target "${LEGACY_TARGET}" > /dev/null
rm -f "${LEGACY_TARGET}/.codex-foundry/manifest.toml"
if "${UPGRADE}" --source "${ROOT_DIR}" --target "${LEGACY_TARGET}" > "${TMP_DIR}/legacy-fail.log" 2>&1; then
  fail "upgrade should refuse legacy repos without --adopt"
fi
assert_contains "${TMP_DIR}/legacy-fail.log" "--adopt"
"${UPGRADE}" --source "${ROOT_DIR}" --target "${LEGACY_TARGET}" --adopt > "${TMP_DIR}/legacy-adopt.log" 2>&1 || fail "upgrade --adopt should create a manifest for legacy repos"
[[ -f "${LEGACY_TARGET}/.codex-foundry/manifest.toml" ]] || fail "upgrade --adopt should create a manifest"
grep -q "Legacy source marker." "${LEGACY_TARGET}/docs/WORKFLOWS.md" || fail "adopt should not overwrite tracked files"
"${UPGRADE}" --source "${ROOT_DIR}" --target "${LEGACY_TARGET}" > "${TMP_DIR}/legacy-upgrade.log" 2>&1 || fail "upgrade should succeed after adopt"
! grep -q "Legacy source marker." "${LEGACY_TARGET}/docs/WORKFLOWS.md" || fail "post-adopt upgrade should refresh managed files"

PROFILE_TARGET="${TMP_DIR}/profile-target"
"${BOOTSTRAP}" --source "${OLD_SOURCE}" --target "${PROFILE_TARGET}" --profile "nextjs-app-router" > /dev/null
grep -q "Legacy nextjs marker." "${PROFILE_TARGET}/docs/STACK-PROFILE.md" || fail "profile target should start from the old overlay source"
"${UPGRADE}" --source "${ROOT_DIR}" --target "${PROFILE_TARGET}" > "${TMP_DIR}/profile-upgrade.log" 2>&1 || fail "upgrade should succeed for a clean profiled repo"
! grep -q "Legacy nextjs marker." "${PROFILE_TARGET}/docs/STACK-PROFILE.md" || fail "upgrade should refresh stack overlays"
assert_contains "${PROFILE_TARGET}/.codex-foundry/manifest.toml" 'active_profile = "nextjs-app-router"'
assert_contains "${PROFILE_TARGET}/.codex-foundry/manifest.toml" 'path = "docs/STACK-PROFILE.md"'
if ! (
  cd "${PROFILE_TARGET}"
  /bin/bash scripts/codex-doctor.sh
) > "${TMP_DIR}/profile-doctor.log" 2>&1; then
  fail "doctor should still succeed after a profile-aware upgrade"
fi

if "${UPGRADE}" --source "${ROOT_DIR}/missing-source" --target "${TMP_DIR}/missing-source-target" > "${TMP_DIR}/missing-source.log" 2>&1; then
  fail "upgrade should fail for a missing source path"
fi
assert_contains "${TMP_DIR}/missing-source.log" "Source path missing"

if "${UPGRADE}" --source "${ROOT_DIR}" --target "${TMP_DIR}/bad-profile-target" --profile "bad-profile" > "${TMP_DIR}/bad-profile.log" 2>&1; then
  fail "upgrade should reject an unknown profile"
fi
assert_contains "${TMP_DIR}/bad-profile.log" "Unknown profile"

echo "upgrade_smoke.sh: OK"
