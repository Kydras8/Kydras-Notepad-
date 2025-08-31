<#
.SYNOPSIS
    Kydras Notepad+ Post-Commit Dashboard Generator
    (Styled + Self-Test + Direct-to-Latest-Run Badge)
.DESCRIPTION
    Generates a branded, badge-rich STATUS.md and updates it after every commit.
    Includes a live Build Status badge that links directly to the latest GitHub Actions run log.
#>

# --- CONFIG ---
$repoOwner = "Kydras8"          # GitHub username/org
$repoName  = "Kydras Notepad+" # Repo name
$branch    = git rev-parse --abbrev-ref HEAD
$token     = $env:GITHUB_TOKEN  # Personal Access Token (needs 'repo' + 'actions:read')

if (-not $token) {
    Write-Host "[Kydras Notepad+] ERROR: GITHUB_TOKEN not set in environment ❌" -ForegroundColor Red
    exit 1
}

# --- Branding Banner ---
$banner = @"
███████╗██╗     ███████╗ ██████╗ █████╗ ███╗   ██╗██████╗ ██╗   ██╗
██╔════╝██║     ██╔════╝██╔════╝██╔══██╗████╗  ██║██╔══██╗╚██╗ ██╔╝
█████╗  ██║     █████╗  ██║     ███████║██╔██╗ ██║██║  ██║ ╚████╔╝ 
██╔══╝  ██║     ██╔══╝  ██║     ██╔══██║██║╚██╗██║██║  ██║  ╚██╔╝  
██║     ███████╗███████╗╚██████╗██║  ██║██║ ╚████║██████╔╝   ██║   
╚═╝     ╚══════╝╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝    ╚═╝   
"@
Write-Host $banner -ForegroundColor Cyan

# --- Gather Repo Info ---
$repoRoot = git rev-parse --show-toplevel 2>$null
if (-not $repoRoot) {
    Write-Host "[Kydras Notepad+] Not inside a Git repo ❌" -ForegroundColor Red
    exit 1
}
Set-Location $repoRoot

$lastCommit   = git log -1 --pretty=format:"%h — %s (%cr) by %an"
$totalCommits = (git rev-list --count HEAD)
$pending      = git status --porcelain | Measure-Object | Select-Object -ExpandProperty Count

# --- Run Self-Test ---
$testScript = Join-Path $repoRoot "scripts/self-test.ps1"
$buildStatus = "unknown"
if (Test-Path $testScript) {
    Write-Host "[Kydras Notepad+] Running self-test..." -ForegroundColor DarkCyan
    try {
        & $testScript
        if ($LASTEXITCODE -eq 0) {
            $buildStatus = "passing"
        } else {
            $buildStatus = "failing"
        }
    } catch {
        $buildStatus = "error"
    }
} else {
    Write-Host "[Kydras Notepad+] No self-test script found — skipping" -ForegroundColor DarkYellow
    $buildStatus = "not_found"
}

# --- Get Latest Workflow Run URL ---
$apiUrl = "https://api.github.com/repos/$repoOwner/$repoName/actions/runs?branch=$branch&per_page=1"
$headers = @{ Authorization = "Bearer $token"; "User-Agent" = "Kydras Notepad+-Dashboard" }
try {
    $latestRun = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Get
    if ($latestRun.workflow_runs.Count -gt 0) {
        $latestRunUrl = $latestRun.workflow_runs[0].html_url
    } else {
        $latestRunUrl = "https://github.com/$repoOwner/$repoName/actions"
    }
} catch {
    Write-Host "[Kydras Notepad+] Could not fetch latest run — defaulting to Actions tab" -ForegroundColor DarkYellow
    $latestRunUrl = "https://github.com/$repoOwner/$repoName/actions"
}

# --- Build Shields.io Badges ---
$badgeBranch  = "![Branch](https://img.shields.io/badge/branch-$branch-blue)"
$badgeCommits = "![Commits](https://img.shields.io/badge/commits-$totalCommits-brightgreen)"
$badgePending = "![Pending](https://img.shields.io/badge/pending_changes-$pending-orange)"

switch ($buildStatus) {
    "passing"   { $badgeBuild = "[![Build](https://img.shields.io/badge/build-passing-brightgreen)]($latestRunUrl)" }
    "failing"   { $badgeBuild = "[![Build](https://img.shields.io/badge/build-failing-red)]($latestRunUrl)" }
    "error"     { $badgeBuild = "[![Build](https://img.shields.io/badge/build-error-lightgrey)]($latestRunUrl)" }
    "not_found" { $badgeBuild = "[![Build](https://img.shields.io/badge/build-no_test-lightgrey)]($latestRunUrl)" }
    default     { $badgeBuild = "[![Build](https://img.shields.io/badge/build-unknown-lightgrey)]($latestRunUrl)" }
}

# --- Build STATUS.md ---
$dashboard = @"
# 📝 Kydras Notepad+ — Status Dashboard

$badgeBranch $badgeCommits $badgePending $badgeBuild  

---

**Branch:** `$branch`  
**Last Commit:** $lastCommit  
**Total Commits:** $totalCommits  
**Pending Changes:** $pending  
**Build Status:** $buildStatus  

---

_Updated automatically on $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")_
"@

# --- Output to Terminal ---
Write-Host "Branch:          $branch" -ForegroundColor Yellow
Write-Host "Last Commit:     $lastCommit" -ForegroundColor Yellow
Write-Host "Total Commits:   $totalCommits" -ForegroundColor Yellow
Write-Host "Pending Changes: $pending" -ForegroundColor Yellow
Write-Host "Build Status:    $buildStatus" -ForegroundColor Yellow
Write-Host "Latest Run URL:  $latestRunUrl" -ForegroundColor Yellow

# --- Save to STATUS.md ---
$dashboard | Set-Content (Join-Path $repoRoot "STATUS.md") -Encoding utf8NoBOM
Write-Host "[Kydras Notepad+] STATUS.md updated with direct run link ✅" -ForegroundColor Green
