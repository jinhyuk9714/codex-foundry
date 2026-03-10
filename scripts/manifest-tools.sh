#!/usr/bin/env bash

cf_is_valid_profile() {
  case "$1" in
    nextjs-app-router|node-api|python-service)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

cf_sha256() {
  local file="$1"

  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$file" | awk '{print $1}'
    return
  fi

  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$file" | awk '{print $1}'
    return
  fi

  openssl dgst -sha256 "$file" | awk '{print $NF}'
}

cf_source_commit() {
  local source_dir="$1"
  if git -C "$source_dir" rev-parse HEAD >/dev/null 2>&1; then
    git -C "$source_dir" rev-parse HEAD
  else
    printf '%s\n' "template-copy"
  fi
}

cf_detect_profile_file() {
  local profile_file="$1"
  local profile_line
  local profile_id

  [[ -f "$profile_file" ]] || return 1
  profile_line="$(grep -E '^Profile ID: ' "$profile_file" | head -n 1 || true)"
  [[ -n "$profile_line" ]] || return 1
  profile_id="${profile_line#Profile ID: }"
  cf_is_valid_profile "$profile_id" || return 1
  printf '%s\n' "$profile_id"
}

cf_manifest_paths=()
cf_manifest_checksums=()
cf_manifest_source_commit=""
cf_manifest_active_profile=""

cf_load_manifest() {
  local manifest_file="$1"
  local current_path=""
  local current_sha=""
  local file_count=0
  local kit_ok=0
  local version_ok=0

  cf_manifest_paths=()
  cf_manifest_checksums=()
  cf_manifest_source_commit=""
  cf_manifest_active_profile=""

  [[ -f "$manifest_file" ]] || return 1

  while IFS= read -r line || [[ -n "$line" ]]; do
    case "$line" in
      'kit = "codex-foundry"')
        kit_ok=1
        ;;
      'manifest_version = 1')
        version_ok=1
        ;;
      'source_commit = "'*'"')
        cf_manifest_source_commit="${line#source_commit = \"}"
        cf_manifest_source_commit="${cf_manifest_source_commit%\"}"
        ;;
      'active_profile = "'*'"')
        cf_manifest_active_profile="${line#active_profile = \"}"
        cf_manifest_active_profile="${cf_manifest_active_profile%\"}"
        ;;
      '[[files]]')
        current_path=""
        current_sha=""
        ;;
      'path = "'*'"')
        current_path="${line#path = \"}"
        current_path="${current_path%\"}"
        ;;
      'sha256 = "'*'"')
        current_sha="${line#sha256 = \"}"
        current_sha="${current_sha%\"}"
        if [[ -n "$current_path" && -n "$current_sha" ]]; then
          cf_manifest_paths+=("$current_path")
          cf_manifest_checksums+=("$current_sha")
          file_count=$((file_count + 1))
          current_path=""
          current_sha=""
        fi
        ;;
    esac
  done < "$manifest_file"

  [[ "$kit_ok" -eq 1 ]] || return 1
  [[ "$version_ok" -eq 1 ]] || return 1
  [[ -n "$cf_manifest_source_commit" ]] || return 1
  if [[ -n "$cf_manifest_active_profile" ]]; then
    cf_is_valid_profile "$cf_manifest_active_profile" || return 1
  fi
  [[ "$file_count" -gt 0 ]] || return 1
  return 0
}

cf_manifest_checksum_for() {
  local path="$1"
  local i
  for ((i=0; i<${#cf_manifest_paths[@]}; i+=1)); do
    if [[ "${cf_manifest_paths[$i]}" == "$path" ]]; then
      printf '%s\n' "${cf_manifest_checksums[$i]}"
      return 0
    fi
  done
  return 1
}

cf_write_manifest() {
  local target_dir="$1"
  local source_commit="$2"
  local active_profile="$3"
  shift 3
  local manifest_dir="$target_dir/.codex-foundry"
  local manifest_file="$manifest_dir/manifest.toml"
  local path
  local file_path
  local checksum

  mkdir -p "$manifest_dir"

  {
    printf 'kit = "codex-foundry"\n'
    printf 'manifest_version = 1\n'
    printf 'source_commit = "%s"\n' "$source_commit"
    printf 'active_profile = "%s"\n' "$active_profile"
    printf '\n'

    for path in "$@"; do
      file_path="$target_dir/$path"
      if [[ -f "$file_path" ]]; then
        checksum="$(cf_sha256 "$file_path")"
        printf '[[files]]\n'
        printf 'path = "%s"\n' "$path"
        printf 'sha256 = "%s"\n' "$checksum"
        printf '\n'
      fi
    done
  } > "$manifest_file"
}

cf_read_list_file() {
  local list_file="$1"
  local output_name="$2"
  local line

  eval "${output_name}=()"
  while IFS= read -r line || [[ -n "$line" ]]; do
    [[ -n "$line" ]] || continue
    [[ "${line}" == \#* ]] && continue
    eval "${output_name}+=(\"\$line\")"
  done < "$list_file"
}

cf_entry() {
  printf '%s::%s\n' "$1" "$2"
}

cf_write_manifest_entries() {
  local target_dir="$1"
  local source_commit="$2"
  local active_profile="$3"
  shift 3
  local manifest_dir="$target_dir/.codex-foundry"
  local manifest_file="$manifest_dir/manifest.toml"
  local entry
  local path
  local checksum

  mkdir -p "$manifest_dir"

  {
    printf 'kit = "codex-foundry"\n'
    printf 'manifest_version = 1\n'
    printf 'source_commit = "%s"\n' "$source_commit"
    printf 'active_profile = "%s"\n' "$active_profile"
    printf '\n'

    for entry in "$@"; do
      path="${entry%%::*}"
      checksum="${entry#*::}"
      [[ -n "$path" && -n "$checksum" ]] || continue
      printf '[[files]]\n'
      printf 'path = "%s"\n' "$path"
      printf 'sha256 = "%s"\n' "$checksum"
      printf '\n'
    done
  } > "$manifest_file"
}
