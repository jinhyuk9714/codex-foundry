[CmdletBinding()]
param(
    [string]$Source = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
    [string]$Target = (Get-Location).Path,
    [string]$Profile = "",
    [switch]$DryRun,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

# bootstrap-files.txt includes public entrypoints such as scripts/upgrade.sh,
# scripts/upgrade.ps1, docs/UPGRADING.md, and the support files needed to
# generate .codex-foundry/manifest.toml.

function Test-ValidProfile {
    param([string]$ProfileId)
    return @("nextjs-app-router", "node-api", "python-service").Contains($ProfileId)
}

function Get-ListFileEntries {
    param([string]$Path)
    return Get-Content -LiteralPath $Path | Where-Object {
        -not [string]::IsNullOrWhiteSpace($_) -and -not $_.TrimStart().StartsWith("#")
    }
}

function Get-SourceCommit {
    param([string]$RepoPath)
    try {
        $sha = git -C $RepoPath rev-parse HEAD 2>$null
        if ($LASTEXITCODE -eq 0 -and $sha) {
            return $sha.Trim()
        }
    } catch {
    }
    return "template-copy"
}

function Write-ManifestFile {
    param(
        [string]$TargetRoot,
        [string]$SourceCommit,
        [string]$ActiveProfile,
        [string[]]$ManagedPaths
    )

    $manifestDir = Join-Path $TargetRoot ".codex-foundry"
    $manifestPath = Join-Path $manifestDir "manifest.toml"
    if (-not (Test-Path -LiteralPath $manifestDir)) {
        New-Item -ItemType Directory -Path $manifestDir -Force | Out-Null
    }

    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add('kit = "codex-foundry"')
    $lines.Add('manifest_version = 1')
    $lines.Add("source_commit = `"$SourceCommit`"")
    $lines.Add("active_profile = `"$ActiveProfile`"")
    $lines.Add("")

    foreach ($managedPath in $ManagedPaths) {
        $absolutePath = Join-Path $TargetRoot $managedPath
        if (-not (Test-Path -LiteralPath $absolutePath -PathType Leaf)) {
            continue
        }

        $hash = (Get-FileHash -Algorithm SHA256 -LiteralPath $absolutePath).Hash.ToLowerInvariant()
        $lines.Add("[[files]]")
        $lines.Add("path = `"$managedPath`"")
        $lines.Add("sha256 = `"$hash`"")
        $lines.Add("")
    }

    Set-Content -LiteralPath $manifestPath -Value $lines
}

if ($Profile -and -not (Test-ValidProfile $Profile)) {
    throw "Unknown profile: $Profile. Allowed profiles: nextjs-app-router, node-api, python-service"
}

$resolvedSource = (Resolve-Path $Source).Path
if (-not (Test-Path -LiteralPath $Target)) {
    New-Item -ItemType Directory -Path $Target | Out-Null
}
$resolvedTarget = (Resolve-Path $Target).Path

$bootstrapList = Get-ListFileEntries (Join-Path $resolvedSource "scripts/bootstrap-files.txt")
$copies = New-Object System.Collections.Generic.List[object]
$manifestPaths = New-Object System.Collections.Generic.List[string]

foreach ($path in $bootstrapList) {
    $copies.Add([PSCustomObject]@{ Source = $path; Target = $path })
    $manifestPaths.Add($path)
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
    $manifestPaths.Add("docs/STACK-PROFILE.md")
    $manifestPaths.Add("docs/STACK-PROMPT-PLAYBOOKS.md")
}

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

$manifestTarget = Join-Path $resolvedTarget ".codex-foundry/manifest.toml"
if ((Test-Path -LiteralPath $manifestTarget) -and -not $Force) {
    throw "Target path already exists: $manifestTarget. Re-run with -Force to overwrite it."
}

Write-Host "Source: $resolvedSource"
Write-Host "Target: $resolvedTarget"
Write-Host "Planned copies:"
foreach ($copy in $copies) {
    Write-Host " - $($copy.Target)"
}
Write-Host " - .codex-foundry/manifest.toml"

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

if ((Test-Path -LiteralPath $manifestTarget) -and $Force) {
    Remove-Item -LiteralPath $manifestTarget -Force
}

Write-ManifestFile -TargetRoot $resolvedTarget -SourceCommit (Get-SourceCommit $resolvedSource) -ActiveProfile $Profile -ManagedPaths $manifestPaths

Write-Host "Bootstrap complete."
Write-Host 'Next step: open the target repo in Codex, run $codex-setup-check, then run bash scripts/codex-doctor.sh.'
