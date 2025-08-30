param (
    [switch]$PreviewOnly,
    [switch]$Verbose,
    [switch]$UndoLastPush
)

# Paths
$base = "C:\LegendaryNotepad"
$pluginsPath = "$base\plugins"
$schemaPath = "$base\schemas\plugin-schema.json"
$dashboardPath = "$base\badges\dashboard.md"
$logPath = "$base\logs\push-log.txt"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$commitMessage = "🔖 Legendary plugin update — $timestamp"

# Logging
function Log($msg) {
    Add-Content $logPath "$((Get-Date).ToString('u')) $msg"
    if ($Verbose) { Write-Host "🧠 $msg" }
}

# Rollback
if ($UndoLastPush) {
    Write-Host "🔁 Rolling back last push..."
    $lastCommit = git log -1 --pretty=format:"%H"
    git revert $lastCommit
    git push origin main
    Write-Host "✅ Rollback complete."
    exit
}

# Detect modified plugins
$modifiedPlugins = git status --porcelain | Where-Object { $_ -match "^ M plugins/" } | ForEach-Object {
    ($_ -split " ")[1] -replace "^plugins/", "" -replace "/.*", ""
} | Sort-Object -Unique

if ($modifiedPlugins.Count -eq 0) {
    Write-Host "✅ No plugin changes detected."
    exit
}

$releaseNotes = @()

foreach ($plugin in $modifiedPlugins) {
    $pluginPath = Join-Path $pluginsPath $plugin
    $manifestPath = Join-Path $pluginPath "plugin-manifest.json"
    $badgePath = Join-Path $pluginPath "badge.svg"
    $lintPath = Join-Path $pluginPath "manifest-lint-log.txt"

    if ([string]::IsNullOrWhiteSpace($manifestPath) -or -not (Test-Path $manifestPath)) {
        Log "⚠️ [$plugin] Manifest missing or invalid path."
        continue
    }

    try {
        $manifest = Get-Content $manifestPath | ConvertFrom-Json
    } catch {
        Log "❌ [$plugin] Manifest parse error: $($_.Exception.Message)"
        continue
    }

    # Version bump
    $oldVersion = $manifest.version
    $parts = $oldVersion -split "\."
    $parts[2] = [int]$parts[2] + 1
    $newVersion = "$($parts[0]).$($parts[1]).$($parts[2])"
    $manifest.version = $newVersion
    $manifest | ConvertTo-Json -Depth 10 | Set-Content $manifestPath -Encoding UTF8
    Log "🔼 [$plugin] Version bumped: $oldVersion → $newVersion"

    # Badge check
    $badgeStatus = if (Test-Path $badgePath) { "✅" } else { "⚠️ Missing" }
    Log "🏷️ [$plugin] Badge status: $badgeStatus"

    # Hash
    $hash = Get-FileHash $manifestPath -Algorithm SHA256
    Log "🛡️ [$plugin] Manifest hash: $($hash.Hash)"

    # Archive
    $zipPath = "$pluginPath-$newVersion.zip"
    Compress-Archive -Path "$pluginPath\*" -DestinationPath $zipPath -Force
    Log "📦 [$plugin] Archived to $zipPath"

    # Changelog
    $releaseNotes += "### [$plugin] v$newVersion — $timestamp"
    if (Test-Path $lintPath) {
        Get-Content $lintPath | ForEach-Object { $releaseNotes += "• $_" }
    }

    # Dashboard
    Add-Content $dashboardPath "`n| $plugin | $newVersion | $badgeStatus | $($hash.Hash.Substring(0,8)) |"
}

# Write changelog
$releaseNotes | Set-Content "$pluginsPath\CHANGELOG.md" -Encoding UTF8

# Git actions
if ($PreviewOnly) {
    Write-Host "`n🔍 Preview mode active. No Git actions performed."
    Log "🛑 Preview mode enabled."
} else {
    git add plugins
    git commit -m $commitMessage
    git push origin main
    foreach ($plugin in $modifiedPlugins) {
        $manifest = Get-Content "$pluginsPath\$plugin\plugin-manifest.json" | ConvertFrom-Json
        $tag = "$plugin-v$($manifest.version)"
        git tag $tag
        git push origin $tag
        gh release create $tag "$pluginsPath\$plugin-$($manifest.version).zip" --notes "$($releaseNotes -join "`n")"
        Log "🚀 [$plugin] GitHub release created: $tag"
    }
    Write-Host "`n✅ Push complete."
}
