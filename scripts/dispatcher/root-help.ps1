<#
.SYNOPSIS
    Root dispatcher help facade and keyword tables.
    Modularized into dedicated <= 100 line sub-files in ./help/.
#>

$helpSubDir = Join-Path $PSScriptRoot "help"

. (Join-Path $helpSubDir "theme.ps1")
. (Join-Path $helpSubDir "keyword-table.ps1")
. (Join-Path $helpSubDir "raw-help.ps1")
. (Join-Path $helpSubDir "filter-main.ps1")
. (Join-Path $helpSubDir "agy-help.ps1")
