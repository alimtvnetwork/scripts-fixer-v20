# Keyword table: Core tools, Python libraries, and languages

function Write-HelpKeywordTableRow {
    param([string]$Keyword, [string]$Description, [string]$ScriptId)

    $kwCol = 28
    $descCol = 36
    Write-Host "    $($Keyword.PadRight($kwCol))$($Description.PadRight($descCol))$ScriptId"
}

function Show-HelpKeywordsDev {
    Write-HelpKeywordTableRow "vscode, vs-code" "VS Code" "01"
    Write-HelpKeywordTableRow "choco, chocolatey" "choco" "02"
    Write-HelpKeywordTableRow "nodejs, node" "nodejs" "03"
    Write-HelpKeywordTableRow "pnpm" "Node.js + pnpm" "03, 04"
    Write-Host ""

    Write-Host "    Python & Libraries" -ForegroundColor $ThemePrimary
    Write-HelpKeywordTableRow "python, pip" "Python + pip" "05"
    Write-HelpKeywordTableRow "pylibs" "Python + all libraries" "05, 41"
    Write-HelpKeywordTableRow "python-libs, pip-libs" "All pip libraries only" "41"
    Write-HelpKeywordTableRow "ml-libs, ml-full" "ML libraries" "41"
    Write-HelpKeywordTableRow "jupyter+libs" "Jupyter group only" "41"
    Write-HelpKeywordTableRow "viz-libs" "Visualization group" "41"
    Write-HelpKeywordTableRow "web-libs" "Web frameworks group" "41"
    Write-HelpKeywordTableRow "scraping-libs" "Scraping group" "41"
    Write-HelpKeywordTableRow "db-libs" "Database group" "41"
    Write-HelpKeywordTableRow "cv-libs" "Computer Vision group" "41"
    Write-HelpKeywordTableRow "data-libs" "Data tools group" "41"
    Write-HelpKeywordTableRow "python+viz" "Python + viz group" "05, 41"
    Write-HelpKeywordTableRow "python+web" "Python + web group" "05, 41"
    Write-HelpKeywordTableRow "python+scraping" "Python + scraping group" "05, 41"
    Write-HelpKeywordTableRow "python+db" "Python + database group" "05, 41"
    Write-HelpKeywordTableRow "python+cv" "Python + CV group" "05, 41"
    Write-HelpKeywordTableRow "python+data" "Python + data group" "05, 41"
    Write-HelpKeywordTableRow "python+ml" "Python + ML group" "05, 41"
    Write-HelpKeywordTableRow "python+libs, ml-dev" "Python + all libraries" "05, 41"
    Write-HelpKeywordTableRow "python+jupyter" "Python + all libraries" "05, 41"
    Write-HelpKeywordTableRow "pip+jupyter+libs" "Python + all libraries" "05, 41"
    Write-HelpKeywordTableRow "data-science" "Python + data/viz libs" "05, 41"
    Write-HelpKeywordTableRow "ai-dev, deep-learning" "Python + ML libs" "05, 41"
    Write-Host ""

    Write-Host "    Languages & Runtimes" -ForegroundColor $ThemePrimary
    Write-HelpKeywordTableRow "go, golang" "Go" "06"
    Write-HelpKeywordTableRow "git, gh" "Git + LFS + GitHub CLI" "07"
    Write-HelpKeywordTableRow "github-desktop" "github-desktop" "08"
    Write-HelpKeywordTableRow "cpp, c++, gcc" "cpp" "09"
    Write-HelpKeywordTableRow "php, php+phpmyadmin" "PHP + phpMyAdmin (default)" "16"
    Write-HelpKeywordTableRow "php-only" "PHP only" "16"
    Write-HelpKeywordTableRow "phpmyadmin" "phpMyAdmin only" "16"
    Write-HelpKeywordTableRow "powershell, pwsh" "pwsh" "17"
    Write-HelpKeywordTableRow "flutter, dart" "Flutter SDK + Dart" "38"
    Write-HelpKeywordTableRow "dotnet, csharp, .net" "dotnet" "39"
    Write-HelpKeywordTableRow "java, openjdk, jdk" "OpenJDK" "40"
    Write-Host ""
}
