#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

required_files=(
  "README.md"
  "AGENTS.md"
  "LICENSE"
  ".gitignore"
  ".codex/config.example.toml"
  ".codex/mcp/README.md"
  "docs/FIRST-STEPS.md"
  "docs/WORKFLOWS.md"
  "docs/CUSTOMIZATION.md"
  "scripts/bootstrap.sh"
  "scripts/bootstrap.ps1"
)

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

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

assert_file() {
  local path="$1"
  [[ -f "${ROOT_DIR}/${path}" ]] || fail "missing file: ${path}"
}

for file in "${required_files[@]}"; do
  assert_file "${file}"
done

grep -q "Template Repository" "${ROOT_DIR}/README.md" || fail "README missing Template Repository badge marker"
grep -q "MIT License" "${ROOT_DIR}/README.md" || fail "README missing MIT License badge marker"

for skill in "${skills[@]}"; do
  skill_file="${ROOT_DIR}/.agents/skills/${skill}/SKILL.md"
  [[ -f "${skill_file}" ]] || fail "missing skill: ${skill}"
  grep -q "^name: ${skill}$" "${skill_file}" || fail "missing or wrong name frontmatter in ${skill}"
  grep -q "^description: " "${skill_file}" || fail "missing description frontmatter in ${skill}"
done

grep -q "openaiDeveloperDocs" "${ROOT_DIR}/.codex/config.example.toml" || fail "config example must mention openaiDeveloperDocs"
grep -q "context7" "${ROOT_DIR}/.codex/config.example.toml" || fail "config example must mention context7"

for skill in "${skills[@]}"; do
  grep -q "\`${skill}\`" "${ROOT_DIR}/README.md" || fail "README missing skill reference: ${skill}"
  grep -q "\`${skill}\`" "${ROOT_DIR}/docs/WORKFLOWS.md" || fail "WORKFLOWS missing skill reference: ${skill}"
done

if compgen -G "${ROOT_DIR}/.agents/skills/*/agents/openai.yaml" > /dev/null; then
  while IFS= read -r yaml_file; do
    grep -q ":" "${yaml_file}" || fail "invalid openai.yaml (no mapping): ${yaml_file}"
  done < <(find "${ROOT_DIR}/.agents/skills" -path "*/agents/openai.yaml" -type f | sort)
fi

echo "validate_repo.sh: OK"
