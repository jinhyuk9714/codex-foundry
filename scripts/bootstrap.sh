#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bootstrap.sh [--source PATH] [--target PATH] [--profile ID] [--dry-run] [--force]

Copies the codex-foundry kit into an existing repository and writes
.codex-foundry/manifest.toml for future safe upgrades.

Options:
  --source PATH  Source starter-kit repo. Defaults to this script's repo root.
  --target PATH  Target repository. Defaults to the current working directory.
  --profile ID   Optional stack profile: nextjs-app-router, node-api, python-service.
  --dry-run      Print planned copies without writing files.
  --force        Overwrite existing target paths.
  -h, --help     Show this help text.
EOF
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
TARGET_DIR="$(pwd)"
DRY_RUN=0
FORCE=0
PROFILE=""

# shellcheck source=/dev/null
source "${SCRIPT_DIR}/manifest-tools.sh"

# bootstrap-files.txt includes public entrypoints such as scripts/upgrade.sh,
# scripts/upgrade.ps1, docs/UPGRADING.md, and the support files needed to
# generate .codex-foundry/manifest.toml.
declare -a bootstrap_paths=()
declare -a source_paths=()
declare -a target_paths=()
declare -a manifest_paths=()

add_copy() {
  source_paths+=("$1")
  target_paths+=("$2")
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --source)
      SOURCE_DIR="$2"
      shift 2
      ;;
    --target)
      TARGET_DIR="$2"
      shift 2
      ;;
    --profile)
      PROFILE="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --force)
      FORCE=1
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

SOURCE_DIR="$(cd "${SOURCE_DIR}" && pwd)"
mkdir -p "${TARGET_DIR}"
TARGET_DIR="$(cd "${TARGET_DIR}" && pwd)"

if [[ -n "${PROFILE}" ]] && ! cf_is_valid_profile "${PROFILE}"; then
  echo "Unknown profile: ${PROFILE}" >&2
  echo "Allowed profiles: nextjs-app-router, node-api, python-service" >&2
  exit 1
fi

cf_read_list_file "${SOURCE_DIR}/scripts/bootstrap-files.txt" bootstrap_paths

for rel in "${bootstrap_paths[@]}"; do
  add_copy "${rel}" "${rel}"
  manifest_paths+=("${rel}")
done

if [[ -n "${PROFILE}" ]]; then
  add_copy "profiles/${PROFILE}/docs/STACK-PROFILE.md" "docs/STACK-PROFILE.md"
  add_copy "profiles/${PROFILE}/docs/STACK-PROMPT-PLAYBOOKS.md" "docs/STACK-PROMPT-PLAYBOOKS.md"
  manifest_paths+=("docs/STACK-PROFILE.md" "docs/STACK-PROMPT-PLAYBOOKS.md")
fi

for i in "${!source_paths[@]}"; do
  src="${SOURCE_DIR}/${source_paths[$i]}"
  dest="${TARGET_DIR}/${target_paths[$i]}"
  [[ -e "${src}" ]] || {
    echo "Source path missing: ${src}" >&2
    exit 1
  }
  if [[ -e "${dest}" && "${FORCE}" -ne 1 ]]; then
    echo "Target path already exists: ${dest}" >&2
    echo "Re-run with --force to overwrite it." >&2
    exit 1
  fi
done

if [[ -e "${TARGET_DIR}/.codex-foundry/manifest.toml" && "${FORCE}" -ne 1 ]]; then
  echo "Target path already exists: ${TARGET_DIR}/.codex-foundry/manifest.toml" >&2
  echo "Re-run with --force to overwrite it." >&2
  exit 1
fi

echo "Source: ${SOURCE_DIR}"
echo "Target: ${TARGET_DIR}"
echo "Planned copies:"
for rel in "${target_paths[@]}"; do
  echo " - ${rel}"
done
echo " - .codex-foundry/manifest.toml"

if [[ "${DRY_RUN}" -eq 1 ]]; then
  echo "Dry run only. No files were written."
  exit 0
fi

for i in "${!source_paths[@]}"; do
  src="${SOURCE_DIR}/${source_paths[$i]}"
  dest="${TARGET_DIR}/${target_paths[$i]}"
  mkdir -p "$(dirname "${dest}")"
  if [[ -e "${dest}" && "${FORCE}" -eq 1 ]]; then
    rm -rf "${dest}"
  fi
  cp -R "${src}" "${dest}"
done

if [[ -e "${TARGET_DIR}/.codex-foundry/manifest.toml" && "${FORCE}" -eq 1 ]]; then
  rm -f "${TARGET_DIR}/.codex-foundry/manifest.toml"
fi

cf_write_manifest "${TARGET_DIR}" "$(cf_source_commit "${SOURCE_DIR}")" "${PROFILE}" "${manifest_paths[@]}"

echo "Bootstrap complete."
echo "Next step: open the target repo in Codex, run \$codex-setup-check, then run bash scripts/codex-doctor.sh."
