[CmdletBinding()]
param(
    [string]$Source = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
    [string]$Target = (Get-Location).Path,
    [string]$Profile = "",
    [switch]$DryRun,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$basePaths = @(
    "AGENTS.md",
    ".agents/skills/feature-design",
    ".agents/skills/implementation-plan",
    ".agents/skills/tdd-implement",
    ".agents/skills/systematic-debug",
    ".agents/skills/request-code-review",
    ".agents/skills/verification-gate",
    ".agents/skills/finish-branch",
    ".agents/skills/codex-setup-check",
    ".codex/config.example.toml",
    ".codex/config.multi-agent.example.toml",
    ".codex/agents/explorer.toml",
    ".codex/agents/reviewer.toml",
    ".codex/agents/docs-researcher.toml",
    ".codex/mcp/README.md",
    "scripts/codex-doctor.sh",
    "scripts/codex-doctor.ps1",
    "docs/ADVANCED-CODEX-POWER.md",
    "docs/PROMPT-PLAYBOOKS.md",
    "docs/PROMPT-PLAYBOOKS.ko.md",
    "docs/STACK-PROFILES.md",
    "docs/SETUP-DOCTOR.md",
    "docs/FIRST-STEPS.md",
    "docs/WORKFLOWS.md",
    "docs/CUSTOMIZATION.md",
    "profiles/nextjs-app-router/docs/STACK-PROFILE.md",
    "profiles/nextjs-app-router/docs/STACK-PROMPT-PLAYBOOKS.md",
    "profiles/node-api/docs/STACK-PROFILE.md",
    "profiles/node-api/docs/STACK-PROMPT-PLAYBOOKS.md",
    "profiles/python-service/docs/STACK-PROFILE.md",
    "profiles/python-service/docs/STACK-PROMPT-PLAYBOOKS.md"
)

$allowedProfiles = @("nextjs-app-router", "node-api", "python-service")
if ($Profile -and -not $allowedProfiles.Contains($Profile)) {
    throw "Unknown profile: $Profile. Allowed profiles: nextjs-app-router, node-api, python-service"
}

$copies = New-Object System.Collections.Generic.List[object]
foreach ($path in $basePaths) {
    $copies.Add([PSCustomObject]@{ Source = $path; Target = $path })
}
if ($Profile) {
    $copies.Add([PSCustomObject]@{
        Source = "profiles/$Profile/docs/STACK-PROFILE.md"
        Target = "docs/STACK-PROFILE.md"
    })
    $copies.Add([PSCustomObject]@{
        Source = "profiles/$Profile/docs/STACK-PROMPT-PLAYBOOKS.md"
        Target = "docs/STACK-PROMPT-PLAYBOOKS.md"
    })
}

$resolvedSource = (Resolve-Path $Source).Path
if (-not (Test-Path -LiteralPath $Target)) {
    New-Item -ItemType Directory -Path $Target | Out-Null
}
$resolvedTarget = (Resolve-Path $Target).Path

foreach ($copy in $copies) {
    $sourcePath = Join-Path $resolvedSource $copy.Source
    $targetPath = Join-Path $resolvedTarget $copy.Target

    if (-not (Test-Path -LiteralPath $sourcePath)) {
        throw "Source path missing: $sourcePath"
    }

    if ((Test-Path -LiteralPath $targetPath) -and -not $Force) {
        throw "Target path already exists: $targetPath. Re-run with -Force to overwrite it."
    }
}

Write-Host "Source: $resolvedSource"
Write-Host "Target: $resolvedTarget"
Write-Host "Planned copies:"
foreach ($copy in $copies) {
    Write-Host " - $($copy.Target)"
}

if ($DryRun) {
    Write-Host "Dry run only. No files were written."
    exit 0
}

foreach ($copy in $copies) {
    $sourcePath = Join-Path $resolvedSource $copy.Source
    $targetPath = Join-Path $resolvedTarget $copy.Target
    $parentDir = Split-Path -Parent $targetPath

    if (-not (Test-Path -LiteralPath $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }

    if ((Test-Path -LiteralPath $targetPath) -and $Force) {
        Remove-Item -LiteralPath $targetPath -Recurse -Force
    }

    Copy-Item -LiteralPath $sourcePath -Destination $targetPath -Recurse -Force
}

Write-Host "Bootstrap complete."
Write-Host 'Next step: open the target repo in Codex, run $codex-setup-check, then run bash scripts/codex-doctor.sh.'
