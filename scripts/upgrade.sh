#!/usr/bin/env bash

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: upgrade.sh --source PATH --target PATH [--profile ID] [--dry-run] [--adopt]

Safely upgrades codex-foundry-managed files using .codex-foundry/manifest.toml.

Options:
  --source PATH  Source codex-foundry checkout to upgrade from.
  --target PATH  Target repository using codex-foundry.
  --profile ID   Optional profile guard. Must match the tracked active profile.
  --dry-run      Print planned actions without writing files.
  --adopt        Create a manifest for a legacy repo without replacing files.
  -h, --help     Show this help text.
EOF
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# shellcheck source=/dev/null
source "${SCRIPT_DIR}/manifest-tools.sh"

SOURCE_DIR=""
TARGET_DIR=""
PROFILE=""
DRY_RUN=0
ADOPT=0

declare -a canonical_paths=()
declare -a final_entries=()

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
    --adopt)
      ADOPT=1
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

if [[ -n "${PROFILE}" ]] && ! cf_is_valid_profile "${PROFILE}"; then
  echo "Unknown profile: ${PROFILE}" >&2
  echo "Allowed profiles: nextjs-app-router, node-api, python-service" >&2
  exit 1
fi

[[ -n "${SOURCE_DIR}" ]] || {
  echo "Missing required argument: --source PATH" >&2
  exit 1
}
[[ -n "${TARGET_DIR}" ]] || {
  echo "Missing required argument: --target PATH" >&2
  exit 1
}

[[ -d "${SOURCE_DIR}" ]] || {
  echo "Source path missing: ${SOURCE_DIR}" >&2
  exit 1
}
[[ -d "${TARGET_DIR}" ]] || {
  echo "Target path missing: ${TARGET_DIR}" >&2
  exit 1
}

SOURCE_DIR="$(cd "${SOURCE_DIR}" && pwd)"
TARGET_DIR="$(cd "${TARGET_DIR}" && pwd)"

cf_read_list_file "${SOURCE_DIR}/scripts/managed-files.txt" canonical_paths
SOURCE_COMMIT="$(cf_source_commit "${SOURCE_DIR}")"
MANIFEST_FILE="${TARGET_DIR}/.codex-foundry/manifest.toml"

array_contains() {
  local needle="$1"
  shift
  local item
  for item in "$@"; do
    if [[ "${item}" == "${needle}" ]]; then
      return 0
    fi
  done
  return 1
}

append_unique() {
  local value="$1"
  if ! array_contains "${value}" "${canonical_paths[@]}"; then
    canonical_paths+=("${value}")
  fi
}

detect_target_profile() {
  local profile_file="${TARGET_DIR}/docs/STACK-PROFILE.md"
  cf_detect_profile_file "${profile_file}" 2>/dev/null || true
}

ensure_profile_consistency() {
  local tracked_profile="$1"
  local detected_profile="$2"

  if [[ -n "${PROFILE}" && "${PROFILE}" != "${tracked_profile}" ]]; then
    echo "Profile mismatch: manifest tracks '${tracked_profile:-<none>}' but --profile requested '${PROFILE}'." >&2
    exit 1
  fi

  if [[ -n "${tracked_profile}" && -n "${detected_profile}" && "${tracked_profile}" != "${detected_profile}" ]]; then
    echo "Profile mismatch: manifest tracks '${tracked_profile}' but docs/STACK-PROFILE.md declares '${detected_profile}'." >&2
    exit 1
  fi

  if [[ -z "${tracked_profile}" && -n "${detected_profile}" ]]; then
    echo "Profile mismatch: manifest tracks no active profile but docs/STACK-PROFILE.md is present." >&2
    exit 1
  fi
}

copy_managed_file() {
  local rel="$1"
  local active_profile="$2"
  local src
  local dest="${TARGET_DIR}/${rel}"

  src="$(source_path_for "${rel}" "${active_profile}")"
  [[ -f "${src}" ]] || return 1
  mkdir -p "$(dirname "${dest}")"
  cp "${src}" "${dest}"
}

source_path_for() {
  local rel="$1"
  local active_profile="$2"

  case "${rel}" in
    docs/STACK-PROFILE.md|docs/STACK-PROMPT-PLAYBOOKS.md)
      if [[ -n "${active_profile}" ]]; then
        printf '%s/profiles/%s/docs/%s\n' "${SOURCE_DIR}" "${active_profile}" "${rel#docs/}"
        return 0
      fi
      ;;
  esac

  printf '%s/%s\n' "${SOURCE_DIR}" "${rel}"
}

adopt_manifest() {
  local detected_profile="$1"
  local adopt_profile="${detected_profile}"
  local path
  local entries=()

  if [[ -n "${PROFILE}" ]]; then
    if [[ -n "${detected_profile}" && "${PROFILE}" != "${detected_profile}" ]]; then
      echo "Profile mismatch: target declares '${detected_profile}' but --profile requested '${PROFILE}'." >&2
      exit 1
    fi
    adopt_profile="${PROFILE}"
  fi

  if [[ -n "${adopt_profile}" ]]; then
    append_unique "docs/STACK-PROFILE.md"
    append_unique "docs/STACK-PROMPT-PLAYBOOKS.md"
  fi

  for path in "${canonical_paths[@]}"; do
    if [[ -f "${TARGET_DIR}/${path}" ]]; then
      entries+=("$(cf_entry "${path}" "$(cf_sha256 "${TARGET_DIR}/${path}")")")
    fi
  done

  if [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "Source: ${SOURCE_DIR}"
    echo "Target: ${TARGET_DIR}"
    echo "Planned manifest adoption:"
    for path in "${canonical_paths[@]}"; do
      if [[ -f "${TARGET_DIR}/${path}" ]]; then
        echo " - track ${path}"
      fi
    done
    echo " - write .codex-foundry/manifest.toml"
    echo "Dry run only. No files were written."
    return 0
  fi

  cf_write_manifest_entries "${TARGET_DIR}" "${SOURCE_COMMIT}" "${adopt_profile}" "${entries[@]}"
  echo "Adopt complete."
  echo "Next step: run bash scripts/upgrade.sh --source ${SOURCE_DIR} --target ${TARGET_DIR}"
}

run_upgrade() {
  local detected_profile
  local active_profile
  local path
  local current_checksum
  local manifest_checksum
  local source_file
  local target_file
  local source_checksum
  local conflict_count=0
  local updated_count=0
  local added_count=0
  local unchanged_count=0
  local final_checksum
  local output_prefix

  cf_load_manifest "${MANIFEST_FILE}" || {
    echo "Managed manifest exists but is invalid: ${MANIFEST_FILE}" >&2
    exit 1
  }

  detected_profile="$(detect_target_profile)"
  active_profile="${cf_manifest_active_profile}"
  ensure_profile_consistency "${active_profile}" "${detected_profile}"

  if [[ -n "${active_profile}" ]]; then
    append_unique "docs/STACK-PROFILE.md"
    append_unique "docs/STACK-PROMPT-PLAYBOOKS.md"
  fi
  for path in "${cf_manifest_paths[@]}"; do
    append_unique "${path}"
  done

  echo "Source: ${SOURCE_DIR}"
  echo "Target: ${TARGET_DIR}"
  echo "Tracked profile: ${active_profile:-<none>}"

  for path in "${canonical_paths[@]}"; do
    source_file="$(source_path_for "${path}" "${active_profile}")"
    target_file="${TARGET_DIR}/${path}"
    manifest_checksum="$(cf_manifest_checksum_for "${path}" || true)"
    source_checksum=""
    [[ -f "${source_file}" ]] && source_checksum="$(cf_sha256 "${source_file}")"

    if [[ -n "${manifest_checksum}" ]]; then
      if [[ ! -f "${target_file}" ]]; then
        echo "Conflict: managed file is missing locally: ${path}" >&2
        final_entries+=("$(cf_entry "${path}" "${manifest_checksum}")")
        conflict_count=$((conflict_count + 1))
        continue
      fi

      current_checksum="$(cf_sha256 "${target_file}")"
      if [[ "${current_checksum}" != "${manifest_checksum}" ]]; then
        echo "Conflict: local edits detected in ${path}" >&2
        final_entries+=("$(cf_entry "${path}" "${manifest_checksum}")")
        conflict_count=$((conflict_count + 1))
        continue
      fi

      if [[ -n "${source_checksum}" ]]; then
        if [[ "${source_checksum}" != "${current_checksum}" ]]; then
          if [[ "${DRY_RUN}" -eq 1 ]]; then
            echo "Would update ${path}"
          else
            copy_managed_file "${path}" "${active_profile}"
          fi
          updated_count=$((updated_count + 1))
        else
          unchanged_count=$((unchanged_count + 1))
        fi
        final_checksum="${source_checksum}"
      else
        final_checksum="${manifest_checksum}"
        unchanged_count=$((unchanged_count + 1))
      fi

      final_entries+=("$(cf_entry "${path}" "${final_checksum}")")
      continue
    fi

    if [[ -f "${target_file}" ]]; then
      echo "Conflict: untracked target file blocks managed upgrade: ${path}" >&2
      conflict_count=$((conflict_count + 1))
      continue
    fi

    if [[ -n "${source_checksum}" ]]; then
      if [[ "${DRY_RUN}" -eq 1 ]]; then
        echo "Would add ${path}"
      else
        copy_managed_file "${path}" "${active_profile}"
      fi
      final_entries+=("$(cf_entry "${path}" "${source_checksum}")")
      added_count=$((added_count + 1))
    fi
  done

  if [[ "${DRY_RUN}" -eq 1 ]]; then
    echo "Dry run only. No files were written."
  else
    cf_write_manifest_entries "${TARGET_DIR}" "${SOURCE_COMMIT}" "${active_profile}" "${final_entries[@]}"
  fi

  echo "Updated: ${updated_count}, added: ${added_count}, unchanged: ${unchanged_count}, conflicts: ${conflict_count}"

  if ((conflict_count > 0)); then
    exit 1
  fi
}

if [[ ! -f "${MANIFEST_FILE}" ]]; then
  if [[ "${ADOPT}" -eq 1 ]]; then
    adopt_manifest "$(detect_target_profile)"
    exit 0
  fi

  echo "Managed manifest is missing: ${MANIFEST_FILE}" >&2
  echo "This looks like a legacy codex-foundry repo. Re-run with --adopt." >&2
  exit 1
fi

if [[ "${ADOPT}" -eq 1 ]]; then
  echo "Managed manifest already exists: ${MANIFEST_FILE}" >&2
  echo "Run the normal upgrade path without --adopt." >&2
  exit 1
fi

run_upgrade
