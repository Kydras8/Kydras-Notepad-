# update-dashboard.ps1
param(
    [string]$CommitMessage = "chore: update dashboard & branding"
)

# --- BRANDING REPLACEMENTS ---
$OldNames = @(
    "Legendary Notepad",
    "legendary-notepad",
    "Kydras-Notepad-",
    "Kydras Notpade+"
)
$NewName = "Kydras Notepad+"
$NewSlug = "kydras-notepad-plus"

Write-Host "🔍 Updating branding..."
foreach ($Old in $OldNames) {
    Write-Host "   Replacing '$Old' → '$NewName'..."
    git grep -l "$Old" | ForEach-Object {
        (Get-Content $_) -replace [regex]::Escape($Old), $NewName | Set-Content $_
    }
}
Write-Host "   Updating repo slugs..."
git grep -l "legendary-notepad" | ForEach-Object {
    (Get-Content $_) -replace "legendary-notepad", $NewSlug | Set-Content $_
}
git grep -l "Kydras-Notepad-" | ForEach-Object {
    (Get-Content $_) -replace "Kydras-Notepad-", $NewSlug | Set-Content $_
}

# --- DASHBOARD UPDATE LOGIC ---
Write-Host "📊 Regenerating STATUS.md and README badges..."
# Example: call your existing dashboard generator
# Replace with your actual script/command
pwsh ./scripts/dashboard-generator.ps1

# --- GIT COMMIT & PUSH ---
Write-Host "📦 Staging changes..."
git add .

Write-Host "💬 Committing..."
git commit -m $CommitMessage

Write-Host "🚀 Pushing to GitHub..."
git push origin main

Write-Host "✅ Dashboard & branding update complete!"
