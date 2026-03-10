#!/usr/bin/env bash

set -euo pipefail

# Example manual publish commands:
# git tag v0.8.0
# git push origin main
# git push origin v0.8.0
# gh release create v0.8.0 --generate-notes

usage() {
  cat <<'EOF'
Usage: prepare-release.sh [--dry-run]

prepare-release.sh verifies that the repository is ready for a manual tag and
GitHub release publish. It does not create tags or releases for you.
EOF
}

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DRY_RUN=0
SKIP_RELEASE_SMOKE="${CODEX_FOUNDRY_SKIP_RELEASE_SMOKE:-0}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

cd "${ROOT_DIR}"

VERSION="$(tr -d '[:space:]' < VERSION)"
TAG="v${VERSION}"

[[ "${VERSION}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || {
  echo "VERSION is not valid SemVer: ${VERSION}" >&2
  exit 1
}

BRANCH="$(git rev-parse --abbrev-ref HEAD)"
[[ "${BRANCH}" == "main" ]] || {
  echo "current branch is not main: ${BRANCH}" >&2
  exit 1
}

[[ -z "$(git status --porcelain)" ]] || {
  echo "working tree is not clean" >&2
  exit 1
}

grep -q "^## \\[${VERSION//./\\.}\\] - " CHANGELOG.md || {
  echo "CHANGELOG.md does not contain a release section for ${VERSION}" >&2
  exit 1
}

if git rev-parse -q --verify "refs/tags/${TAG}" >/dev/null 2>&1; then
  echo "tag already exists: ${TAG}" >&2
  exit 1
fi

tests=(
  "bash tests/validate_repo.sh"
  "bash tests/bootstrap_safety.sh"
  "bash tests/profile_smoke.sh"
  "bash tests/doctor_smoke.sh"
  "bash tests/upgrade_smoke.sh"
)

if [[ "${SKIP_RELEASE_SMOKE}" != "1" ]]; then
  tests+=("bash tests/release_smoke.sh")
fi

for cmd in "${tests[@]}"; do
  echo "Running: ${cmd}"
  eval "${cmd}"
done

echo "prepare-release.sh verified version ${VERSION}."
if [[ "${DRY_RUN}" -eq 1 ]]; then
  echo "Dry run only. No git tags or releases were created."
else
  echo "No tag or release was created. Run the commands below manually."
fi
echo "Next commands:"
echo "git tag ${TAG}"
echo "git push origin main"
echo "git push origin ${TAG}"
echo "gh release create ${TAG} --generate-notes"
