#Requires -Version 5.1
<#
.SYNOPSIS
    Mirror agent skills from .agents/skills/ into ~/.claude/skills/.

.DESCRIPTION
    Copies every directory containing a SKILL.md from this folder into
    $env:USERPROFILE\.claude\skills\ so Claude has an up-to-date copy of each
    skill. Safe to re-run: existing files are overwritten in place.

    This script NEVER deletes skills. It only creates or overwrites files so the
    destination contains an equivalent copy of every source skill. Skills present
    only in the destination (installed by other means, or removed from source)
    are left untouched.

    Collision policy: overwrite individual files; never remove directories.
#>

[CmdletBinding()]
param(
    [string]$Source      = $PSScriptRoot,
    [string]$Destination = (Join-Path $env:USERPROFILE '.claude\skills'),
    [switch]$WhatIfOnly
)

$ErrorActionPreference = 'Stop'

function Get-SourceSkills {
    param([string]$Root)
    Get-ChildItem -LiteralPath $Root -Directory |
        Where-Object { Test-Path -LiteralPath (Join-Path $_.FullName 'SKILL.md') -PathType Leaf } |
        ForEach-Object { $_.Name }
}

# True only when the destination file exists and already matches the source
# byte-for-byte. Lets us skip files that don't need updating (including ones
# that may be locked by another process).
function Test-FilesIdentical {
    param([string]$A, [string]$B)
    if (-not (Test-Path -LiteralPath $B)) { return $false }
    $ia = Get-Item -LiteralPath $A -Force
    $ib = Get-Item -LiteralPath $B -Force
    if ($ia.Length -ne $ib.Length) { return $false }
    $ha = (Get-FileHash -LiteralPath $A -Algorithm SHA256).Hash
    $hb = (Get-FileHash -LiteralPath $B -Algorithm SHA256).Hash
    return $ha -eq $hb
}

# Copy one file, retrying briefly if the destination is locked by another
# process (e.g. Claude Code holding SKILL.md open).
function Copy-FileWithRetry {
    param(
        [string]$From,
        [string]$To,
        [int]$Retries = 3,
        [int]$DelayMs = 400
    )
    for ($attempt = 1; $attempt -le $Retries; $attempt++) {
        try {
            Copy-Item -LiteralPath $From -Destination $To -Force
            return $true
        } catch [System.IO.IOException] {
            if ($attempt -eq $Retries) {
                Write-Warning "Skipped (in use): $To"
                return $false
            }
            Start-Sleep -Milliseconds $DelayMs
        }
    }
}

# Copy a skill's contents into the destination, overwriting existing files but
# never deleting anything that is already there.
function Copy-SkillTree {
    param(
        [string]$SourceDir,
        [string]$DestDir,
        [switch]$DryRun
    )

    if (-not $DryRun -and -not (Test-Path -LiteralPath $DestDir)) {
        New-Item -ItemType Directory -Path $DestDir -Force | Out-Null
    }

    $srcRoot = (Resolve-Path -LiteralPath $SourceDir).Path

    Get-ChildItem -LiteralPath $SourceDir -Recurse -Force | ForEach-Object {
        $relative = $_.FullName.Substring($srcRoot.Length).TrimStart('\', '/')
        $target   = Join-Path $DestDir $relative

        if ($_.PSIsContainer) {
            if (-not $DryRun -and -not (Test-Path -LiteralPath $target)) {
                New-Item -ItemType Directory -Path $target -Force | Out-Null
            }
        } else {
            # Skip files that are already identical — avoids touching locked
            # files that don't need updating in the first place.
            if (Test-FilesIdentical -A $_.FullName -B $target) { return }

            if (-not $DryRun) {
                $parent = Split-Path -Parent $target
                if (-not (Test-Path -LiteralPath $parent)) {
                    New-Item -ItemType Directory -Path $parent -Force | Out-Null
                }
                Copy-FileWithRetry -From $_.FullName -To $target | Out-Null
            }
        }
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

$currentSkills = @(Get-SourceSkills -Root $Source)
if ($currentSkills.Count -eq 0) {
    Write-Warning "No skills (directories containing SKILL.md) found under $Source"
}

# Copy each current skill, overwriting files in place. Nothing is ever deleted.
foreach ($name in $currentSkills) {
    $src = Join-Path $Source $name
    $dst = Join-Path $Destination $name

    if (Test-Path -LiteralPath $dst) {
        Write-Host "Updating: $name"
    } else {
        Write-Host "Installing: $name"
    }

    Copy-SkillTree -SourceDir $src -DestDir $dst -DryRun:$WhatIfOnly
}

Write-Host ""
Write-Host "Done. $($currentSkills.Count) skill(s) synced to $Destination"
