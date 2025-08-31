$OldNames = @(
    "Legendary Notepad",
    "legendary-notepad",
    "Kydras-Notepad-",
    "Kydras Notpade+"
)
$NewName = "Kydras Notepad+"
$NewSlug = "kydras-notepad-plus"

Write-Host "🔍 Searching and replacing old names with '$NewName' and slug '$NewSlug'..."
foreach ($Old in $OldNames) {
    Write-Host "   Replacing '$Old' → '$NewName'..."
    git grep -l "$Old" | ForEach-Object {
        (Get-Content $_) -replace [regex]::Escape($Old), $NewName | Set-Content $_
    }
}
Write-Host "   Replacing repo slugs..."
git grep -l "legendary-notepad" | ForEach-Object {
    (Get-Content $_) -replace "legendary-notepad", $NewSlug | Set-Content $_
}
git grep -l "Kydras-Notepad-" | ForEach-Object {
    (Get-Content $_) -replace "Kydras-Notepad-", $NewSlug | Set-Content $_
}

Write-Host "📦 Staging changes..."
git add .
Write-Host "💬 Committing..."
git commit -m "chore: rebrand project to $NewName"
Write-Host "🚀 Pushing to GitHub..."
git push origin main
Write-Host "✅ Rebrand complete! Remember to rename the repo in GitHub settings to match '$NewSlug'."
