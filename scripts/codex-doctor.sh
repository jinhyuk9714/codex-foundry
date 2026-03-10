#!/usr/bin/env bash

set -uo pipefail

SCRIPT_SOURCE="${BASH_SOURCE[0]}"
SCRIPT_DIR="${SCRIPT_SOURCE%/*}"
if [[ "${SCRIPT_DIR}" == "${SCRIPT_SOURCE}" ]]; then
  SCRIPT_DIR="."
fi
ROOT_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

# shellcheck source=/dev/null
source "${SCRIPT_DIR}/manifest-tools.sh"

skills=(
  "feature-design"
  "implementation-plan"
  "tdd-implement"
  "systematic-debug"
  "request-code-review"
  "verification-gate"
  "finish-branch"
  "codex-setup-check"
)

pass_count=0
warn_count=0
fail_count=0
declare -a next_steps=()

join_list() {
  local result=""
  local item
  for item in "$@"; do
    if [[ -n "${result}" ]]; then
      result="${result}, "
    fi
    result="${result}${item}"
  done
  printf '%s' "${result}"
}

contains_literal() {
  local file="$1"
  local needle="$2"
  grep -Fq -- "${needle}" "${file}" 2>/dev/null
}

add_next_step() {
  local step="$1"
  local existing
  [[ -n "${step}" ]] || return
  if ((${#next_steps[@]} > 0)); then
    for existing in "${next_steps[@]}"; do
      [[ "${existing}" == "${step}" ]] && return
    done
  fi
  if ((${#next_steps[@]} < 3)); then
    next_steps+=("${step}")
  fi
}

report_pass() {
  printf '[PASS] %s\n' "$1"
  ((pass_count += 1))
}

report_warn() {
  printf '[WARN] %s\n' "$1"
  ((warn_count += 1))
}

report_fail() {
  printf '[FAIL] %s\n' "$1"
  ((fail_count += 1))
}

check_root_agents() {
  if [[ -f "${ROOT_DIR}/AGENTS.md" ]]; then
    report_pass "Root AGENTS.md is present."
  else
    report_fail "Root AGENTS.md is missing."
    add_next_step "bash tests/validate_repo.sh"
  fi
}

check_skills() {
  local missing=()
  local skill
  for skill in "${skills[@]}"; do
    if [[ ! -f "${ROOT_DIR}/.agents/skills/${skill}/SKILL.md" ]]; then
      missing+=("${skill}")
    fi
  done

  if ((${#missing[@]} == 0)); then
    report_pass "All eight repo-local skills are present."
  else
    report_fail "Missing repo-local skills: $(join_list "${missing[@]}")."
    add_next_step "bash tests/validate_repo.sh"
  fi
}

check_skill_metadata() {
  local issues=()
  local skill
  local meta_file

  for skill in "${skills[@]}"; do
    meta_file="${ROOT_DIR}/.agents/skills/${skill}/agents/openai.yaml"
    if [[ ! -f "${meta_file}" ]]; then
      issues+=("${skill}:missing")
      continue
    fi
    contains_literal "${meta_file}" "display_name:" || issues+=("${skill}:display_name")
    contains_literal "${meta_file}" "short_description:" || issues+=("${skill}:short_description")
    contains_literal "${meta_file}" "default_prompt:" || issues+=("${skill}:default_prompt")
  done

  if ((${#issues[@]} == 0)); then
    report_pass "All skill metadata files are present."
  else
    report_fail "Missing or incomplete skill metadata: $(join_list "${issues[@]}")."
    add_next_step "bash tests/validate_repo.sh"
  fi
}

check_minimal_config() {
  local missing=()
  [[ -f "${ROOT_DIR}/.codex/config.example.toml" ]] || missing+=(".codex/config.example.toml")
  [[ -f "${ROOT_DIR}/.codex/mcp/README.md" ]] || missing+=(".codex/mcp/README.md")

  if ((${#missing[@]} == 0)); then
    report_pass "Minimal .codex examples are present."
  else
    report_fail "Missing minimal .codex files: $(join_list "${missing[@]}")."
    add_next_step "bash tests/validate_repo.sh"
  fi
}

check_multi_agent_example() {
  local config_file="${ROOT_DIR}/.codex/config.multi-agent.example.toml"
  local issues=()

  [[ -f "${config_file}" ]] || issues+=(".codex/config.multi-agent.example.toml")
  [[ -f "${ROOT_DIR}/.codex/agents/explorer.toml" ]] || issues+=(".codex/agents/explorer.toml")
  [[ -f "${ROOT_DIR}/.codex/agents/reviewer.toml" ]] || issues+=(".codex/agents/reviewer.toml")
  [[ -f "${ROOT_DIR}/.codex/agents/docs-researcher.toml" ]] || issues+=(".codex/agents/docs-researcher.toml")

  if [[ -f "${config_file}" ]]; then
    contains_literal "${config_file}" "features.multi_agent = true" || issues+=("config:multi_agent")
    contains_literal "${config_file}" "[agents.explorer]" || issues+=("config:explorer")
    contains_literal "${config_file}" "[agents.reviewer]" || issues+=("config:reviewer")
    contains_literal "${config_file}" "[agents.docs_researcher]" || issues+=("config:docs_researcher")
    contains_literal "${config_file}" 'config_file = "agents/explorer.toml"' || issues+=("config:explorer-ref")
    contains_literal "${config_file}" 'config_file = "agents/reviewer.toml"' || issues+=("config:reviewer-ref")
    contains_literal "${config_file}" 'config_file = "agents/docs-researcher.toml"' || issues+=("config:docs-ref")
  fi

  if ((${#issues[@]} == 0)); then
    report_pass "Advanced example files are present and consistent."
  else
    report_fail "Advanced example files are incomplete: $(join_list "${issues[@]}")."
    add_next_step "bash tests/validate_repo.sh"
  fi
}

valid_stack_profile_id() {
  case "$1" in
    nextjs-app-router|node-api|python-service)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

check_stack_overlay() {
  local profile_file="${ROOT_DIR}/docs/STACK-PROFILE.md"
  local prompt_file="${ROOT_DIR}/docs/STACK-PROMPT-PLAYBOOKS.md"
  local issues=()
  local profile_line=""
  local profile_id=""

  if [[ ! -f "${profile_file}" && ! -f "${prompt_file}" ]]; then
    return
  fi

  [[ -f "${profile_file}" ]] || issues+=("docs/STACK-PROFILE.md")
  [[ -f "${prompt_file}" ]] || issues+=("docs/STACK-PROMPT-PLAYBOOKS.md")

  if [[ -f "${profile_file}" ]]; then
    profile_line="$(grep -E '^Profile ID: ' "${profile_file}" | head -n 1 || true)"
    if [[ -z "${profile_line}" ]]; then
      issues+=("profile:id")
    else
      profile_id="${profile_line#Profile ID: }"
      if ! valid_stack_profile_id "${profile_id}"; then
        issues+=("profile:unknown-id")
      fi
    fi
  fi

  if [[ -f "${prompt_file}" ]]; then
    contains_literal "${prompt_file}" "## Bootstrap Playbook" || issues+=("prompt:bootstrap")
    contains_literal "${prompt_file}" "## Feature Playbook" || issues+=("prompt:feature")
    contains_literal "${prompt_file}" "## Bugfix Playbook" || issues+=("prompt:bugfix")
  fi

  if ((${#issues[@]} == 0)); then
    report_pass "Stack profile overlay is present: ${profile_id}."
  else
    report_fail "Stack profile overlay is incomplete: $(join_list "${issues[@]}")."
    add_next_step "bash tests/profile_smoke.sh"
  fi
}

check_manifest() {
  local manifest_file="${ROOT_DIR}/.codex-foundry/manifest.toml"

  if [[ ! -f "${manifest_file}" ]]; then
    report_warn "Managed manifest is missing. This looks like a legacy repo."
    add_next_step "bash scripts/upgrade.sh --source /path/to/codex-foundry --target . --adopt"
    return
  fi

  if cf_load_manifest "${manifest_file}"; then
    report_pass "Managed manifest is present and well-formed."
  else
    report_fail "Managed manifest is present but invalid: .codex-foundry/manifest.toml."
    add_next_step "bash scripts/upgrade.sh --source /path/to/codex-foundry --target . --adopt"
  fi
}

check_project_config() {
  local config_file="${ROOT_DIR}/.codex/config.toml"
  local missing_roles=()
  local has_role_refs=0

  if [[ ! -f "${config_file}" ]]; then
    return
  fi

  report_warn "Project-scoped .codex/config.toml only loads in trusted projects."
  add_next_step "/debug-config"

  if contains_literal "${config_file}" 'config_file = "agents/explorer.toml"'; then
    has_role_refs=1
    [[ -f "${ROOT_DIR}/.codex/agents/explorer.toml" ]] || missing_roles+=("agents/explorer.toml")
  fi
  if contains_literal "${config_file}" 'config_file = "agents/reviewer.toml"'; then
    has_role_refs=1
    [[ -f "${ROOT_DIR}/.codex/agents/reviewer.toml" ]] || missing_roles+=("agents/reviewer.toml")
  fi
  if contains_literal "${config_file}" 'config_file = "agents/docs-researcher.toml"'; then
    has_role_refs=1
    [[ -f "${ROOT_DIR}/.codex/agents/docs-researcher.toml" ]] || missing_roles+=("agents/docs-researcher.toml")
  fi

  if ((has_role_refs)); then
    if ((${#missing_roles[@]} == 0)); then
      report_pass ".codex/config.toml references valid role files."
    else
      report_fail ".codex/config.toml references missing role files: $(join_list "${missing_roles[@]}")."
      add_next_step "/debug-config"
    fi
  fi
}

check_environment() {
  local project_config="${ROOT_DIR}/.codex/config.toml"
  local context7_enabled=0

  if [[ -f "${project_config}" ]] && contains_literal "${project_config}" "context7"; then
    context7_enabled=1
  fi

  if command -v git >/dev/null 2>&1; then
    report_pass "git is available."
  else
    report_warn "git is not on PATH."
    add_next_step "bash tests/validate_repo.sh"
  fi

  if command -v codex >/dev/null 2>&1; then
    report_pass "codex is available."
    add_next_step "/status"
  else
    report_warn "codex is not on PATH."
  fi

  if command -v npx >/dev/null 2>&1; then
    report_pass "npx is available."
  else
    if ((context7_enabled)); then
      report_warn "context7 is configured in .codex/config.toml but npx is not available."
      add_next_step "/mcp"
    else
      report_warn "npx is not on PATH. This only matters if you enable context7."
    fi
  fi

  if command -v pwsh >/dev/null 2>&1; then
    report_pass "pwsh is available."
  else
    report_warn "pwsh is not on PATH. Use the shell doctor and shell bootstrap scripts on this machine."
  fi
}

check_root_agents
check_skills
check_skill_metadata
check_minimal_config
check_multi_agent_example
check_stack_overlay
check_manifest
check_project_config
check_environment

printf 'Summary: %d pass, %d warn, %d fail\n' "${pass_count}" "${warn_count}" "${fail_count}"

if ((${#next_steps[@]} == 0)); then
  add_next_step "bash tests/validate_repo.sh"
fi

printf 'Try now:\n'
for step in "${next_steps[@]}"; do
  printf ' - %s\n' "${step}"
done

if ((fail_count > 0)); then
  exit 1
fi
