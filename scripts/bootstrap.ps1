[CmdletBinding()]
param(
    [string]$Source = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
    [string]$Target = (Get-Location).Path,
    [switch]$DryRun,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$paths = @(
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
    ".codex/mcp/README.md",
    "docs/FIRST-STEPS.md",
    "docs/WORKFLOWS.md",
    "docs/CUSTOMIZATION.md"
)

$resolvedSource = (Resolve-Path $Source).Path
if (-not (Test-Path -LiteralPath $Target)) {
    New-Item -ItemType Directory -Path $Target | Out-Null
}
$resolvedTarget = (Resolve-Path $Target).Path

foreach ($relativePath in $paths) {
    $sourcePath = Join-Path $resolvedSource $relativePath
    $targetPath = Join-Path $resolvedTarget $relativePath

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
foreach ($relativePath in $paths) {
    Write-Host " - $relativePath"
}

if ($DryRun) {
    Write-Host "Dry run only. No files were written."
    exit 0
}

foreach ($relativePath in $paths) {
    $sourcePath = Join-Path $resolvedSource $relativePath
    $targetPath = Join-Path $resolvedTarget $relativePath
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
Write-Host 'Next step: open the target repo in Codex and run $codex-setup-check.'
