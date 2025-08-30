<#
.SYNOPSIS
    Legendary Notepad Post-Commit Dashboard Generator
.DESCRIPTION
    Generates a branded status dashboard in the terminal and updates STATUS.md
    so the latest repo state is visible on GitHub.
#>

# --- Branding Banner ---
Write-Host "══════════════════════════════════════════════════════" -ForegroundColor DarkCyan
Write-Host "   Legendary Notepad — Post-Commit Dashboard" -ForegroundColor Cyan
Write-Host "══════════════════════════════════════════════════════" -ForegroundColor DarkCyan

# --- Gather Repo Info ---
$repoRoot = git rev-parse --show-toplevel 2>$null
if (-not $repoRoot) {
    Write-Host "[Legendary Notepad] Not inside a Git repo ❌" -ForegroundColor Red
    exit 1
}

Set-Location $repoRoot

$branch     = git rev-parse --abbrev-ref HEAD
$lastCommit = git log -1 --pretty=format:"%h — %s (%cr) by %an"
$totalCommits = (git rev-list --count HEAD)
$pending    = git status --porcelain | Measure-Object | Select-Object -ExpandProperty Count

# --- Build Dashboard Text ---
$dashboard = @"
# 📝 Legendary Notepad — Status Dashboard

**Branch:** $branch  
**Last Commit:** $lastCommit  
**Total Commits:** $totalCommits  
**Pending Changes:** $pending  

---

Generated on $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
"@

# --- Output to Terminal ---
Write-Host "Branch:          $branch" -ForegroundColor Yellow
Write-Host "Last Commit:     $lastCommit" -ForegroundColor Yellow
Write-Host "Total Commits:   $totalCommits" -ForegroundColor Yellow
Write-Host "Pending Changes: $pending" -ForegroundColor Yellow

# --- Save to STATUS.md ---
$dashboard | Set-Content (Join-Path $repoRoot "STATUS.md") -Encoding utf8NoBOM
Write-Host "[Legendary Notepad] STATUS.md updated ✅" -ForegroundColor Green
