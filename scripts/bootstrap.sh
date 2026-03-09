#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bootstrap.sh [--source PATH] [--target PATH] [--dry-run] [--force]

Copies codex-foundry into an existing repository.

Options:
  --source PATH  Source starter-kit repo. Defaults to this script's repo root.
  --target PATH  Target repository. Defaults to the current working directory.
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

paths=(
  "AGENTS.md"
  ".agents/skills/feature-design"
  ".agents/skills/implementation-plan"
  ".agents/skills/tdd-implement"
  ".agents/skills/systematic-debug"
  ".agents/skills/request-code-review"
  ".agents/skills/verification-gate"
  ".agents/skills/finish-branch"
  ".agents/skills/codex-setup-check"
  ".codex/config.example.toml"
  ".codex/config.multi-agent.example.toml"
  ".codex/agents/explorer.toml"
  ".codex/agents/reviewer.toml"
  ".codex/agents/docs-researcher.toml"
  ".codex/mcp/README.md"
  "scripts/codex-doctor.sh"
  "scripts/codex-doctor.ps1"
  "docs/ADVANCED-CODEX-POWER.md"
  "docs/SETUP-DOCTOR.md"
  "docs/FIRST-STEPS.md"
  "docs/WORKFLOWS.md"
  "docs/CUSTOMIZATION.md"
)

for rel in "${paths[@]}"; do
  src="${SOURCE_DIR}/${rel}"
  dest="${TARGET_DIR}/${rel}"
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

echo "Source: ${SOURCE_DIR}"
echo "Target: ${TARGET_DIR}"
echo "Planned copies:"
for rel in "${paths[@]}"; do
  echo " - ${rel}"
done

if [[ "${DRY_RUN}" -eq 1 ]]; then
  echo "Dry run only. No files were written."
  exit 0
fi

for rel in "${paths[@]}"; do
  src="${SOURCE_DIR}/${rel}"
  dest="${TARGET_DIR}/${rel}"
  mkdir -p "$(dirname "${dest}")"
  if [[ -e "${dest}" && "${FORCE}" -eq 1 ]]; then
    rm -rf "${dest}"
  fi
  cp -R "${src}" "${dest}"
done

echo "Bootstrap complete."
echo "Next step: open the target repo in Codex, run \$codex-setup-check, then run bash scripts/codex-doctor.sh."
