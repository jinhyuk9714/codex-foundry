[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

$rootDir = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$skills = @(
    "feature-design",
    "implementation-plan",
    "tdd-implement",
    "systematic-debug",
    "request-code-review",
    "verification-gate",
    "finish-branch",
    "codex-setup-check"
)

$passCount = 0
$warnCount = 0
$failCount = 0
$nextSteps = New-Object System.Collections.Generic.List[string]

function Add-NextStep {
    param([string]$Step)
    if ([string]::IsNullOrWhiteSpace($Step)) { return }
    if (-not $nextSteps.Contains($Step) -and $nextSteps.Count -lt 3) {
        $nextSteps.Add($Step)
    }
}

function Report-Pass {
    param([string]$Message)
    Write-Host "[PASS] $Message"
    $script:passCount += 1
}

function Report-Warn {
    param([string]$Message)
    Write-Host "[WARN] $Message"
    $script:warnCount += 1
}

function Report-Fail {
    param([string]$Message)
    Write-Host "[FAIL] $Message"
    $script:failCount += 1
}

function Join-Items {
    param([string[]]$Items)
    return ($Items -join ", ")
}

function Test-FileContains {
    param(
        [string]$Path,
        [string]$Pattern
    )
    if (-not (Test-Path -LiteralPath $Path)) {
        return $false
    }
    return Select-String -Path $Path -SimpleMatch -Pattern $Pattern -Quiet
}

function Test-ValidStackProfileId {
    param([string]$ProfileId)
    return @("nextjs-app-router", "node-api", "python-service").Contains($ProfileId)
}

$agentsPath = Join-Path $rootDir "AGENTS.md"
if (Test-Path -LiteralPath $agentsPath) {
    Report-Pass "Root AGENTS.md is present."
} else {
    Report-Fail "Root AGENTS.md is missing."
    Add-NextStep "bash tests/validate_repo.sh"
}

$missingSkills = New-Object System.Collections.Generic.List[string]
foreach ($skill in $skills) {
    $skillPath = Join-Path $rootDir ".agents/skills/$skill/SKILL.md"
    if (-not (Test-Path -LiteralPath $skillPath)) {
        $missingSkills.Add($skill)
    }
}
if ($missingSkills.Count -eq 0) {
    Report-Pass "All eight repo-local skills are present."
} else {
    Report-Fail "Missing repo-local skills: $(Join-Items $missingSkills)."
    Add-NextStep "bash tests/validate_repo.sh"
}

$metadataIssues = New-Object System.Collections.Generic.List[string]
foreach ($skill in $skills) {
    $metaFile = Join-Path $rootDir ".agents/skills/$skill/agents/openai.yaml"
    if (-not (Test-Path -LiteralPath $metaFile)) {
        $metadataIssues.Add("$skill:missing")
        continue
    }
    if (-not (Test-FileContains $metaFile "display_name:")) { $metadataIssues.Add("$skill:display_name") }
    if (-not (Test-FileContains $metaFile "short_description:")) { $metadataIssues.Add("$skill:short_description") }
    if (-not (Test-FileContains $metaFile "default_prompt:")) { $metadataIssues.Add("$skill:default_prompt") }
}
if ($metadataIssues.Count -eq 0) {
    Report-Pass "All skill metadata files are present."
} else {
    Report-Fail "Missing or incomplete skill metadata: $(Join-Items $metadataIssues)."
    Add-NextStep "bash tests/validate_repo.sh"
}

$minimalMissing = New-Object System.Collections.Generic.List[string]
if (-not (Test-Path -LiteralPath (Join-Path $rootDir ".codex/config.example.toml"))) { $minimalMissing.Add(".codex/config.example.toml") }
if (-not (Test-Path -LiteralPath (Join-Path $rootDir ".codex/mcp/README.md"))) { $minimalMissing.Add(".codex/mcp/README.md") }
if ($minimalMissing.Count -eq 0) {
    Report-Pass "Minimal .codex examples are present."
} else {
    Report-Fail "Missing minimal .codex files: $(Join-Items $minimalMissing)."
    Add-NextStep "bash tests/validate_repo.sh"
}

$advancedIssues = New-Object System.Collections.Generic.List[string]
$multiAgentExample = Join-Path $rootDir ".codex/config.multi-agent.example.toml"
if (-not (Test-Path -LiteralPath $multiAgentExample)) { $advancedIssues.Add(".codex/config.multi-agent.example.toml") }
if (-not (Test-Path -LiteralPath (Join-Path $rootDir ".codex/agents/explorer.toml"))) { $advancedIssues.Add(".codex/agents/explorer.toml") }
if (-not (Test-Path -LiteralPath (Join-Path $rootDir ".codex/agents/reviewer.toml"))) { $advancedIssues.Add(".codex/agents/reviewer.toml") }
if (-not (Test-Path -LiteralPath (Join-Path $rootDir ".codex/agents/docs-researcher.toml"))) { $advancedIssues.Add(".codex/agents/docs-researcher.toml") }
if (Test-Path -LiteralPath $multiAgentExample) {
    if (-not (Test-FileContains $multiAgentExample "features.multi_agent = true")) { $advancedIssues.Add("config:multi_agent") }
    if (-not (Test-FileContains $multiAgentExample "[agents.explorer]")) { $advancedIssues.Add("config:explorer") }
    if (-not (Test-FileContains $multiAgentExample "[agents.reviewer]")) { $advancedIssues.Add("config:reviewer") }
    if (-not (Test-FileContains $multiAgentExample "[agents.docs_researcher]")) { $advancedIssues.Add("config:docs_researcher") }
    if (-not (Test-FileContains $multiAgentExample 'config_file = "agents/explorer.toml"')) { $advancedIssues.Add("config:explorer-ref") }
    if (-not (Test-FileContains $multiAgentExample 'config_file = "agents/reviewer.toml"')) { $advancedIssues.Add("config:reviewer-ref") }
    if (-not (Test-FileContains $multiAgentExample 'config_file = "agents/docs-researcher.toml"')) { $advancedIssues.Add("config:docs-ref") }
}
if ($advancedIssues.Count -eq 0) {
    Report-Pass "Advanced example files are present and consistent."
} else {
    Report-Fail "Advanced example files are incomplete: $(Join-Items $advancedIssues)."
    Add-NextStep "bash tests/validate_repo.sh"
}

$stackProfilePath = Join-Path $rootDir "docs/STACK-PROFILE.md"
$stackPromptPath = Join-Path $rootDir "docs/STACK-PROMPT-PLAYBOOKS.md"
if ((Test-Path -LiteralPath $stackProfilePath) -or (Test-Path -LiteralPath $stackPromptPath)) {
    $stackIssues = New-Object System.Collections.Generic.List[string]
    $profileId = ""

    if (-not (Test-Path -LiteralPath $stackProfilePath)) { $stackIssues.Add("docs/STACK-PROFILE.md") }
    if (-not (Test-Path -LiteralPath $stackPromptPath)) { $stackIssues.Add("docs/STACK-PROMPT-PLAYBOOKS.md") }

    if (Test-Path -LiteralPath $stackProfilePath) {
        $profileLine = Select-String -Path $stackProfilePath -Pattern "^Profile ID: " | Select-Object -First 1
        if (-not $profileLine) {
            $stackIssues.Add("profile:id")
        } else {
            $profileId = $profileLine.Line.Substring("Profile ID: ".Length)
            if (-not (Test-ValidStackProfileId $profileId)) {
                $stackIssues.Add("profile:unknown-id")
            }
        }
    }

    if (Test-Path -LiteralPath $stackPromptPath) {
        if (-not (Test-FileContains $stackPromptPath "## Bootstrap Playbook")) { $stackIssues.Add("prompt:bootstrap") }
        if (-not (Test-FileContains $stackPromptPath "## Feature Playbook")) { $stackIssues.Add("prompt:feature") }
        if (-not (Test-FileContains $stackPromptPath "## Bugfix Playbook")) { $stackIssues.Add("prompt:bugfix") }
    }

    if ($stackIssues.Count -eq 0) {
        Report-Pass "Stack profile overlay is present: $profileId."
    } else {
        Report-Fail "Stack profile overlay is incomplete: $(Join-Items $stackIssues)."
        Add-NextStep "bash tests/profile_smoke.sh"
    }
}

$projectConfig = Join-Path $rootDir ".codex/config.toml"
if (Test-Path -LiteralPath $projectConfig) {
    Report-Warn "Project-scoped .codex/config.toml only loads in trusted projects."
    Add-NextStep "/debug-config"

    $missingRoleRefs = New-Object System.Collections.Generic.List[string]
    $hasRoleRef = $false

    if (Test-FileContains $projectConfig 'config_file = "agents/explorer.toml"') {
        $hasRoleRef = $true
        if (-not (Test-Path -LiteralPath (Join-Path $rootDir ".codex/agents/explorer.toml"))) { $missingRoleRefs.Add("agents/explorer.toml") }
    }
    if (Test-FileContains $projectConfig 'config_file = "agents/reviewer.toml"') {
        $hasRoleRef = $true
        if (-not (Test-Path -LiteralPath (Join-Path $rootDir ".codex/agents/reviewer.toml"))) { $missingRoleRefs.Add("agents/reviewer.toml") }
    }
    if (Test-FileContains $projectConfig 'config_file = "agents/docs-researcher.toml"') {
        $hasRoleRef = $true
        if (-not (Test-Path -LiteralPath (Join-Path $rootDir ".codex/agents/docs-researcher.toml"))) { $missingRoleRefs.Add("agents/docs-researcher.toml") }
    }

    if ($hasRoleRef) {
        if ($missingRoleRefs.Count -eq 0) {
            Report-Pass ".codex/config.toml references valid role files."
        } else {
            Report-Fail ".codex/config.toml references missing role files: $(Join-Items $missingRoleRefs)."
            Add-NextStep "/debug-config"
        }
    }
}

$context7Enabled = $false
if ((Test-Path -LiteralPath $projectConfig) -and (Test-FileContains $projectConfig "context7")) {
    $context7Enabled = $true
}

if (Get-Command git -ErrorAction SilentlyContinue) {
    Report-Pass "git is available."
} else {
    Report-Warn "git is not on PATH."
    Add-NextStep "bash tests/validate_repo.sh"
}

if (Get-Command codex -ErrorAction SilentlyContinue) {
    Report-Pass "codex is available."
    Add-NextStep "/status"
} else {
    Report-Warn "codex is not on PATH."
}

if (Get-Command npx -ErrorAction SilentlyContinue) {
    Report-Pass "npx is available."
} else {
    if ($context7Enabled) {
        Report-Warn "context7 is configured in .codex/config.toml but npx is not available."
        Add-NextStep "/mcp"
    } else {
        Report-Warn "npx is not on PATH. This only matters if you enable context7."
    }
}

if (Get-Command pwsh -ErrorAction SilentlyContinue) {
    Report-Pass "pwsh is available."
} else {
    Report-Warn "pwsh is not on PATH. Use the shell doctor and shell bootstrap scripts on this machine."
}

Write-Host "Summary: $passCount pass, $warnCount warn, $failCount fail"

if ($nextSteps.Count -eq 0) {
    Add-NextStep "bash tests/validate_repo.sh"
}

Write-Host "Try now:"
foreach ($step in $nextSteps) {
    Write-Host " - $step"
}

if ($failCount -gt 0) {
    exit 1
}
