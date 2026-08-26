<#
.SYNOPSIS
Fixes CRLF line endings and Git file caching issues across the repository.

.DESCRIPTION
This script forces Git to renormalize all files according to .gitattributes 
(converting Windows CRLF to Unix LF for shell scripts). It also repairs
local working trees that are out-of-sync due to case-insensitivity on Windows.
#>

Write-Host "[INFO] Forcing Git to renormalize all files to match .gitattributes..." -ForegroundColor Cyan
git add --renormalize .

Write-Host "[INFO] Resetting working tree to ensure physical files match the Git index..." -ForegroundColor Cyan
git checkout .

Write-Host "[INFO] Normalization complete! Line endings and file casing are now correct." -ForegroundColor Green
