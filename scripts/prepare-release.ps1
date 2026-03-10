[CmdletBinding()]
param(
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

$rootDir = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
Set-Location $rootDir

$version = (Get-Content -LiteralPath "VERSION" -Raw).Trim()
if ($version -notmatch '^\d+\.\d+\.\d+$') {
    throw "VERSION is not valid SemVer: $version"
}

$tag = "v$version"
$branch = (git rev-parse --abbrev-ref HEAD).Trim()
if ($branch -ne "main") {
    throw "current branch is not main: $branch"
}

$status = git status --porcelain
if ($status) {
    throw "working tree is not clean"
}

$releasePattern = "^## \[$([regex]::Escape($version))\] - "
if (-not (Select-String -Path "CHANGELOG.md" -Pattern $releasePattern -Quiet)) {
    throw "CHANGELOG.md does not contain a release section for $version"
}

git rev-parse -q --verify "refs/tags/$tag" *> $null
if ($LASTEXITCODE -eq 0) {
    throw "tag already exists: $tag"
}

$tests = @(
    "bash tests/validate_repo.sh",
    "bash tests/bootstrap_safety.sh",
    "bash tests/profile_smoke.sh",
    "bash tests/doctor_smoke.sh",
    "bash tests/upgrade_smoke.sh"
)
if ($env:CODEX_FOUNDRY_SKIP_RELEASE_SMOKE -ne "1") {
    $tests += "bash tests/release_smoke.sh"
}

foreach ($cmd in $tests) {
    Write-Host "Running: $cmd"
    bash -lc $cmd
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}

Write-Host "prepare-release.ps1 verified version $version."
if ($DryRun) {
    Write-Host "Dry run only. No git tags or releases were created."
} else {
    Write-Host "No tag or release was created. Run the commands below manually."
}
Write-Host "Next commands:"
Write-Host "git tag $tag"
Write-Host "git push origin main"
Write-Host "git push origin $tag"
Write-Host "gh release create $tag --generate-notes"
