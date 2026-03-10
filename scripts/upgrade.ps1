[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Source,
    [Parameter(Mandatory = $true)]
    [string]$Target,
    [string]$Profile = "",
    [switch]$DryRun,
    [switch]$Adopt
)

$ErrorActionPreference = "Stop"

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

function Get-PathHash {
    param([string]$Path)
    return (Get-FileHash -Algorithm SHA256 -LiteralPath $Path).Hash.ToLowerInvariant()
}

function Get-ProfileFromOverlay {
    param([string]$TargetRoot)
    $profilePath = Join-Path $TargetRoot "docs/STACK-PROFILE.md"
    if (-not (Test-Path -LiteralPath $profilePath)) {
        return ""
    }

    $line = Select-String -Path $profilePath -Pattern "^Profile ID: " | Select-Object -First 1
    if (-not $line) {
        return ""
    }

    $profileId = $line.Line.Substring("Profile ID: ".Length)
    if (-not (Test-ValidProfile $profileId)) {
        throw "Unknown profile declared in docs/STACK-PROFILE.md: $profileId"
    }
    return $profileId
}

function Get-SourcePathForManagedFile {
    param(
        [string]$SourceRoot,
        [string]$ManagedPath,
        [string]$ActiveProfile
    )

    switch ($ManagedPath) {
        "docs/STACK-PROFILE.md" {
            if ($ActiveProfile) {
                return (Join-Path $SourceRoot "profiles/$ActiveProfile/docs/STACK-PROFILE.md")
            }
        }
        "docs/STACK-PROMPT-PLAYBOOKS.md" {
            if ($ActiveProfile) {
                return (Join-Path $SourceRoot "profiles/$ActiveProfile/docs/STACK-PROMPT-PLAYBOOKS.md")
            }
        }
    }

    return (Join-Path $SourceRoot $ManagedPath)
}

function Read-Manifest {
    param([string]$ManifestPath)
    if (-not (Test-Path -LiteralPath $ManifestPath)) {
        return $null
    }

    $content = Get-Content -LiteralPath $ManifestPath
    $manifest = [ordered]@{
        kit = ""
        manifest_version = ""
        source_commit = ""
        active_profile = ""
        files = [ordered]@{}
    }

    $currentPath = ""
    foreach ($line in $content) {
        switch -Regex ($line) {
            '^kit = "(.+)"$' { $manifest.kit = $Matches[1] }
            '^manifest_version = (.+)$' { $manifest.manifest_version = $Matches[1] }
            '^source_commit = "(.+)"$' { $manifest.source_commit = $Matches[1] }
            '^active_profile = "(.*)"$' { $manifest.active_profile = $Matches[1] }
            '^path = "(.+)"$' { $currentPath = $Matches[1] }
            '^sha256 = "(.+)"$' {
                if ($currentPath) {
                    $manifest.files[$currentPath] = $Matches[1]
                    $currentPath = ""
                }
            }
        }
    }

    if ($manifest.kit -ne "codex-foundry" -or $manifest.manifest_version -ne "1" -or -not $manifest.source_commit) {
        throw "Managed manifest is present but invalid: $ManifestPath"
    }

    return $manifest
}

function Write-Manifest {
    param(
        [string]$TargetRoot,
        [string]$SourceCommit,
        [string]$ActiveProfile,
        [hashtable]$Entries
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

    foreach ($path in ($Entries.Keys | Sort-Object)) {
        $lines.Add("[[files]]")
        $lines.Add("path = `"$path`"")
        $lines.Add("sha256 = `"$($Entries[$path])`"")
        $lines.Add("")
    }

    Set-Content -LiteralPath $manifestPath -Value $lines
}

if ($Profile -and -not (Test-ValidProfile $Profile)) {
    throw "Unknown profile: $Profile. Allowed profiles: nextjs-app-router, node-api, python-service"
}

$resolvedSource = (Resolve-Path $Source).Path
$resolvedTarget = (Resolve-Path $Target).Path
$manifestPath = Join-Path $resolvedTarget ".codex-foundry/manifest.toml"
$sourceCommit = Get-SourceCommit $resolvedSource
$canonicalPaths = New-Object System.Collections.Generic.List[string]
foreach ($path in (Get-ListFileEntries (Join-Path $resolvedSource "scripts/managed-files.txt"))) {
    $canonicalPaths.Add($path)
}

if (-not (Test-Path -LiteralPath $manifestPath)) {
    if (-not $Adopt) {
        throw "Managed manifest is missing: $manifestPath. Re-run with -Adopt."
    }

    $detectedProfile = Get-ProfileFromOverlay $resolvedTarget
    if ($Profile -and $detectedProfile -and $Profile -ne $detectedProfile) {
        throw "Profile mismatch: target declares '$detectedProfile' but -Profile requested '$Profile'."
    }

    $activeProfile = if ($detectedProfile) { $detectedProfile } else { $Profile }
    if ($activeProfile) {
        if (-not $canonicalPaths.Contains("docs/STACK-PROFILE.md")) { $canonicalPaths.Add("docs/STACK-PROFILE.md") }
        if (-not $canonicalPaths.Contains("docs/STACK-PROMPT-PLAYBOOKS.md")) { $canonicalPaths.Add("docs/STACK-PROMPT-PLAYBOOKS.md") }
    }

    $entries = [ordered]@{}
    foreach ($managedPath in $canonicalPaths) {
        $targetPath = Join-Path $resolvedTarget $managedPath
        if (Test-Path -LiteralPath $targetPath -PathType Leaf) {
            $entries[$managedPath] = Get-PathHash $targetPath
        }
    }

    if ($DryRun) {
        Write-Host "Source: $resolvedSource"
        Write-Host "Target: $resolvedTarget"
        Write-Host "Planned manifest adoption:"
        foreach ($path in $entries.Keys) {
            Write-Host " - track $path"
        }
        Write-Host " - write .codex-foundry/manifest.toml"
        Write-Host "Dry run only. No files were written."
        exit 0
    }

    Write-Manifest -TargetRoot $resolvedTarget -SourceCommit $sourceCommit -ActiveProfile $activeProfile -Entries $entries
    Write-Host "Adopt complete."
    Write-Host "Next step: run pwsh -File scripts/upgrade.ps1 -Source $resolvedSource -Target $resolvedTarget"
    exit 0
}

if ($Adopt) {
    throw "Managed manifest already exists: $manifestPath. Run the normal upgrade path without -Adopt."
}

$manifest = Read-Manifest $manifestPath
$detectedProfile = Get-ProfileFromOverlay $resolvedTarget
$activeProfile = $manifest.active_profile

if ($Profile -and $Profile -ne $activeProfile) {
    throw "Profile mismatch: manifest tracks '$activeProfile' but -Profile requested '$Profile'."
}
if ($activeProfile -and $detectedProfile -and $activeProfile -ne $detectedProfile) {
    throw "Profile mismatch: manifest tracks '$activeProfile' but docs/STACK-PROFILE.md declares '$detectedProfile'."
}
if (-not $activeProfile -and $detectedProfile) {
    throw "Profile mismatch: manifest tracks no active profile but docs/STACK-PROFILE.md is present."
}

if ($activeProfile) {
    if (-not $canonicalPaths.Contains("docs/STACK-PROFILE.md")) { $canonicalPaths.Add("docs/STACK-PROFILE.md") }
    if (-not $canonicalPaths.Contains("docs/STACK-PROMPT-PLAYBOOKS.md")) { $canonicalPaths.Add("docs/STACK-PROMPT-PLAYBOOKS.md") }
}
foreach ($path in $manifest.files.Keys) {
    if (-not $canonicalPaths.Contains($path)) {
        $canonicalPaths.Add($path)
    }
}

$finalEntries = [ordered]@{}
$conflictCount = 0
$updatedCount = 0
$addedCount = 0
$unchangedCount = 0

Write-Host "Source: $resolvedSource"
Write-Host "Target: $resolvedTarget"
Write-Host "Tracked profile: $(if ($activeProfile) { $activeProfile } else { '<none>' })"

foreach ($managedPath in $canonicalPaths) {
    $targetPath = Join-Path $resolvedTarget $managedPath
    $sourcePath = Get-SourcePathForManagedFile -SourceRoot $resolvedSource -ManagedPath $managedPath -ActiveProfile $activeProfile
    $hasManifestPath = $manifest.files.Contains($managedPath)
    $hasSourcePath = Test-Path -LiteralPath $sourcePath -PathType Leaf

    if ($hasManifestPath) {
        $manifestHash = $manifest.files[$managedPath]
        if (-not (Test-Path -LiteralPath $targetPath -PathType Leaf)) {
            Write-Error "Conflict: managed file is missing locally: $managedPath"
            $finalEntries[$managedPath] = $manifestHash
            $conflictCount += 1
            continue
        }

        $currentHash = Get-PathHash $targetPath
        if ($currentHash -ne $manifestHash) {
            Write-Error "Conflict: local edits detected in $managedPath"
            $finalEntries[$managedPath] = $manifestHash
            $conflictCount += 1
            continue
        }

        if ($hasSourcePath) {
            $sourceHash = Get-PathHash $sourcePath
            if ($sourceHash -ne $currentHash) {
                if ($DryRun) {
                    Write-Host "Would update $managedPath"
                } else {
                    $parentDir = Split-Path -Parent $targetPath
                    if (-not (Test-Path -LiteralPath $parentDir)) {
                        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
                    }
                    Copy-Item -LiteralPath $sourcePath -Destination $targetPath -Force
                }
                $updatedCount += 1
            } else {
                $unchangedCount += 1
            }
            $finalEntries[$managedPath] = $sourceHash
        } else {
            $unchangedCount += 1
            $finalEntries[$managedPath] = $manifestHash
        }

        continue
    }

    if (Test-Path -LiteralPath $targetPath -PathType Leaf) {
        Write-Error "Conflict: untracked target file blocks managed upgrade: $managedPath"
        $conflictCount += 1
        continue
    }

    if ($hasSourcePath) {
        $sourceHash = Get-PathHash $sourcePath
        if ($DryRun) {
            Write-Host "Would add $managedPath"
        } else {
            $parentDir = Split-Path -Parent $targetPath
            if (-not (Test-Path -LiteralPath $parentDir)) {
                New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
            }
            Copy-Item -LiteralPath $sourcePath -Destination $targetPath -Force
        }
        $finalEntries[$managedPath] = $sourceHash
        $addedCount += 1
    }
}

if (-not $DryRun) {
    Write-Manifest -TargetRoot $resolvedTarget -SourceCommit $sourceCommit -ActiveProfile $activeProfile -Entries $finalEntries
} else {
    Write-Host "Dry run only. No files were written."
}

Write-Host "Updated: $updatedCount, added: $addedCount, unchanged: $unchangedCount, conflicts: $conflictCount"

if ($conflictCount -gt 0) {
    exit 1
}
