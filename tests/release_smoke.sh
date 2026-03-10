#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_contains() {
  local file="$1"
  local pattern="$2"
  grep -q -- "${pattern}" "${file}" || fail "expected ${file} to contain ${pattern}"
}

make_clean_repo() {
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

  git -C "${dest}" init -q
  git -C "${dest}" config user.name "Codex Test"
  git -C "${dest}" config user.email "codex@example.com"
  git -C "${dest}" add -A
  git -C "${dest}" commit -qm "fixture"
  git -C "${dest}" branch -M main
}

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "${TMP_DIR}"' EXIT

assert_contains "${ROOT_DIR}/VERSION" '^0\.8\.0$'
assert_contains "${ROOT_DIR}/CHANGELOG.md" '^## \[0\.8\.0\] - 2026-03-10$'

CLEAN_REPO="${TMP_DIR}/clean"
make_clean_repo "${CLEAN_REPO}"
if ! (
  cd "${CLEAN_REPO}"
  CODEX_FOUNDRY_SKIP_RELEASE_SMOKE=1 bash scripts/prepare-release.sh --dry-run
) > "${TMP_DIR}/clean.log" 2>&1; then
  fail "prepare-release --dry-run should succeed in a clean release-ready repo"
fi
assert_contains "${TMP_DIR}/clean.log" 'git tag v0.8.0'
assert_contains "${TMP_DIR}/clean.log" 'git push origin main'
assert_contains "${TMP_DIR}/clean.log" 'git push origin v0.8.0'
assert_contains "${TMP_DIR}/clean.log" 'gh release create v0.8.0 --generate-notes'

DIRTY_REPO="${TMP_DIR}/dirty"
make_clean_repo "${DIRTY_REPO}"
printf '\nlocal edit\n' >> "${DIRTY_REPO}/README.md"
if (
  cd "${DIRTY_REPO}"
  CODEX_FOUNDRY_SKIP_RELEASE_SMOKE=1 bash scripts/prepare-release.sh --dry-run
) > "${TMP_DIR}/dirty.log" 2>&1; then
  fail "prepare-release should fail when the working tree is dirty"
fi
assert_contains "${TMP_DIR}/dirty.log" 'working tree is not clean'

CHANGELOG_REPO="${TMP_DIR}/bad-changelog"
make_clean_repo "${CHANGELOG_REPO}"
sed -i.bak 's/^## \[0\.8\.0\] - 2026-03-10$/## [0.7.9] - 2026-03-09/' "${CHANGELOG_REPO}/CHANGELOG.md"
rm -f "${CHANGELOG_REPO}/CHANGELOG.md.bak"
git -C "${CHANGELOG_REPO}" add CHANGELOG.md
git -C "${CHANGELOG_REPO}" commit -qm "mismatch changelog"
if (
  cd "${CHANGELOG_REPO}"
  CODEX_FOUNDRY_SKIP_RELEASE_SMOKE=1 bash scripts/prepare-release.sh --dry-run
) > "${TMP_DIR}/bad-changelog.log" 2>&1; then
  fail "prepare-release should fail when CHANGELOG.md does not match VERSION"
fi
assert_contains "${TMP_DIR}/bad-changelog.log" 'CHANGELOG.md does not contain a release section for 0.8.0'

TAG_REPO="${TMP_DIR}/tagged"
make_clean_repo "${TAG_REPO}"
git -C "${TAG_REPO}" tag v0.8.0
if (
  cd "${TAG_REPO}"
  CODEX_FOUNDRY_SKIP_RELEASE_SMOKE=1 bash scripts/prepare-release.sh --dry-run
) > "${TMP_DIR}/tagged.log" 2>&1; then
  fail "prepare-release should fail when the version tag already exists"
fi
assert_contains "${TMP_DIR}/tagged.log" 'tag already exists: v0.8.0'

echo "release_smoke.sh: OK"
