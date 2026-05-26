#Requires -Version 5.1
<#
.SYNOPSIS
    Mirror agent skills from .agents/skills/ into ~/.claude/skills/.

.DESCRIPTION
    Copies every directory containing a SKILL.md from this folder into
    $env:USERPROFILE\.claude\skills\. Safe to re-run: a manifest file tracks
    which skills claudify installed, so re-runs reflect source deletions
    without disturbing skills installed by other means.

    Collision policy: overwrite always.
#>

[CmdletBinding()]
param(
    [string]$Source      = $PSScriptRoot,
    [string]$Destination = (Join-Path $env:USERPROFILE '.claude\skills'),
    [switch]$WhatIfOnly
)

$ErrorActionPreference = 'Stop'
$ManifestName = '.claudified'

function Get-SourceSkills {
    param([string]$Root)
    Get-ChildItem -LiteralPath $Root -Directory |
        Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'SKILL.md') -PathType Leaf } |
        ForEach-Object { $_.Name }
}

function Remove-SkillTarget {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return }

    # Handle symlinks/junctions: Remove-Item -Recurse follows them on older
    # PowerShell. Detect reparse points and unlink without recursing.
    $item = Get-Item -LiteralPath $Path -Force
    if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) {
        # Use .NET to delete the link itself, not its target.
        [IO.Directory]::Delete($Path)
    } else {
        Remove-Item -LiteralPath $Path -Recurse -Force
    }
}

if (-not (Test-Path -LiteralPath $Source)) {
    throw "Source not found: $Source"
}
if (-not (Test-Path -LiteralPath $Destination)) {
    Write-Host "Creating destination: $Destination"
    if (-not $WhatIfOnly) {
        New-Item -ItemType Directory -Path $Destination -Force | Out-Null
    }
}

$manifestPath = Join-Path $Destination $ManifestName
$previousSkills = @()
if (Test-Path -LiteralPath $manifestPath) {
    $previousSkills = Get-Content -LiteralPath $manifestPath |
        Where-Object { $_ -and -not $_.StartsWith('#') } |
        ForEach-Object { $_.Trim() }
}

$currentSkills = @(Get-SourceSkills -Root $Source)
if ($currentSkills.Count -eq 0) {
    Write-Warning "No skills (directories containing SKILL.md) found under $Source"
}

# 1. Remove skills that were previously claudified but no longer exist in source.
$stale = $previousSkills | Where-Object { $_ -notin $currentSkills }
foreach ($name in $stale) {
    $target = Join-Path $Destination $name
    if (Test-Path -LiteralPath $target) {
        Write-Host "Removing stale skill: $name"
        if (-not $WhatIfOnly) { Remove-SkillTarget -Path $target }
    }
}

# 2. Copy each current skill, overwriting anything in the way.
foreach ($name in $currentSkills) {
    $src = Join-Path $Source $name
    $dst = Join-Path $Destination $name

    if (Test-Path -LiteralPath $dst) {
        Write-Host "Replacing: $name"
        if (-not $WhatIfOnly) { Remove-SkillTarget -Path $dst }
    } else {
        Write-Host "Installing: $name"
    }

    if (-not $WhatIfOnly) {
        Copy-Item -LiteralPath $src -Destination $dst -Recurse -Force
    }
}

# 3. Write the manifest so the next run knows what we own.
if (-not $WhatIfOnly) {
    $header = @(
        '# Skills installed by claudify.ps1. Do not edit manually.',
        "# Source: $Source",
        "# Updated: $(Get-Date -Format o)"
    )
    ($header + $currentSkills) | Set-Content -LiteralPath $manifestPath -Encoding UTF8
}

Write-Host ""
Write-Host "Done. $($currentSkills.Count) skill(s) synced to $Destination"
if ($stale.Count -gt 0) {
    Write-Host "Removed $($stale.Count) stale skill(s): $($stale -join ', ')"
}
