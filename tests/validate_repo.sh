#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

required_files=(
  "README.md"
  "README.ko.md"
  "AGENTS.md"
  "LICENSE"
  ".gitignore"
  ".codex/config.example.toml"
  ".codex/config.multi-agent.example.toml"
  ".codex/agents/explorer.toml"
  ".codex/agents/reviewer.toml"
  ".codex/agents/docs-researcher.toml"
  ".codex/mcp/README.md"
  "docs/FIRST-STEPS.md"
  "docs/WORKFLOWS.md"
  "docs/CUSTOMIZATION.md"
  "docs/ADVANCED-CODEX-POWER.md"
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
  meta_file="${ROOT_DIR}/.agents/skills/${skill}/agents/openai.yaml"
  [[ -f "${meta_file}" ]] || fail "missing skill metadata: ${skill}"
  grep -q "display_name:" "${meta_file}" || fail "missing display_name in ${skill} metadata"
  grep -q "short_description:" "${meta_file}" || fail "missing short_description in ${skill} metadata"
  grep -q "default_prompt:" "${meta_file}" || fail "missing default_prompt in ${skill} metadata"
done

grep -q "openaiDeveloperDocs" "${ROOT_DIR}/.codex/config.example.toml" || fail "config example must mention openaiDeveloperDocs"
grep -q "context7" "${ROOT_DIR}/.codex/config.example.toml" || fail "config example must mention context7"
grep -q "features.multi_agent = true" "${ROOT_DIR}/.codex/config.multi-agent.example.toml" || fail "multi-agent example must enable features.multi_agent"
grep -q "\\[agents\\.explorer\\]" "${ROOT_DIR}/.codex/config.multi-agent.example.toml" || fail "multi-agent example must define explorer"
grep -q "\\[agents\\.reviewer\\]" "${ROOT_DIR}/.codex/config.multi-agent.example.toml" || fail "multi-agent example must define reviewer"
grep -q "\\[agents\\.docs_researcher\\]" "${ROOT_DIR}/.codex/config.multi-agent.example.toml" || fail "multi-agent example must define docs_researcher"
grep -q "config_file = \"agents/explorer.toml\"" "${ROOT_DIR}/.codex/config.multi-agent.example.toml" || fail "multi-agent example must reference explorer config"
grep -q "config_file = \"agents/reviewer.toml\"" "${ROOT_DIR}/.codex/config.multi-agent.example.toml" || fail "multi-agent example must reference reviewer config"
grep -q "config_file = \"agents/docs-researcher.toml\"" "${ROOT_DIR}/.codex/config.multi-agent.example.toml" || fail "multi-agent example must reference docs researcher config"

for skill in "${skills[@]}"; do
  grep -q "\`${skill}\`" "${ROOT_DIR}/README.md" || fail "README missing skill reference: ${skill}"
  grep -q "\`${skill}\`" "${ROOT_DIR}/docs/WORKFLOWS.md" || fail "WORKFLOWS missing skill reference: ${skill}"
done

grep -q "Advanced Codex Power" "${ROOT_DIR}/README.md" || fail "README missing Advanced Codex Power section"
grep -q "고급 Codex 기능" "${ROOT_DIR}/README.ko.md" || fail "Korean README missing advanced power section"
grep -q "multi-agent" "${ROOT_DIR}/docs/ADVANCED-CODEX-POWER.md" || fail "advanced power doc must describe multi-agent usage"
grep -q "^## What It Is$" "${ROOT_DIR}/README.md" || fail "README missing What It Is section"
grep -q "^## Start Here$" "${ROOT_DIR}/README.md" || fail "README missing Start Here section"
grep -q "^## Default Workflow$" "${ROOT_DIR}/README.md" || fail "README missing Default Workflow section"
grep -q "^## What's Included$" "${ROOT_DIR}/README.md" || fail "README missing What's Included section"
grep -q "^## 이 프로젝트는 무엇인가$" "${ROOT_DIR}/README.ko.md" || fail "Korean README missing project intro section"
grep -q "^## 바로 시작하기$" "${ROOT_DIR}/README.ko.md" || fail "Korean README missing quick start section"
grep -q "^## 기본 워크플로우$" "${ROOT_DIR}/README.ko.md" || fail "Korean README missing workflow section"
grep -q "^## 포함 내용$" "${ROOT_DIR}/README.ko.md" || fail "Korean README missing included items section"
grep -q "Use this template" "${ROOT_DIR}/README.md" || fail "README must mention Use this template"
grep -q "bootstrap.sh" "${ROOT_DIR}/README.md" || fail "README must mention bootstrap.sh"
grep -Fq '$codex-setup-check' "${ROOT_DIR}/README.md" || fail 'README must mention $codex-setup-check'
grep -q "bootstrap.sh" "${ROOT_DIR}/README.ko.md" || fail "Korean README must mention bootstrap.sh"
grep -Fq '$codex-setup-check' "${ROOT_DIR}/README.ko.md" || fail 'Korean README must mention $codex-setup-check'
! grep -q "Claude Forge Translation" "${ROOT_DIR}/README.md" || fail "README should not contain Claude Forge Translation section"
! grep -q "Claude Forge 방식과의 대응" "${ROOT_DIR}/README.ko.md" || fail "Korean README should not contain Claude Forge comparison section"
! grep -q "Repository Layout" "${ROOT_DIR}/README.md" || fail "README should not contain Repository Layout section"
! grep -q "저장소 구조" "${ROOT_DIR}/README.ko.md" || fail "Korean README should not contain repository layout section"

if compgen -G "${ROOT_DIR}/.agents/skills/*/agents/openai.yaml" > /dev/null; then
  while IFS= read -r yaml_file; do
    grep -q ":" "${yaml_file}" || fail "invalid openai.yaml (no mapping): ${yaml_file}"
  done < <(find "${ROOT_DIR}/.agents/skills" -path "*/agents/openai.yaml" -type f | sort)
fi

echo "validate_repo.sh: OK"
