# Fail fast for errors
$ErrorActionPreference = "Stop"

# Example checks (customize to your repo)
git rev-parse --is-inside-work-tree | Out-Null
Test-Path "README.md" | Out-Null

# Simulate your checks here; exit 0 = pass, non-zero = fail
exit 0
