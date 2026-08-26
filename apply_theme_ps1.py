import re

run_ps1 = "run.ps1"
with open(run_ps1, "r", encoding="utf-8") as f:
    ps1 = f.read()

theme_loader = """$ThemePath = Join-Path $RootDir "scripts\\shared\\theme.json"
$ThemePrimary = "Magenta"
$ThemeSecondary = "Cyan"
$ThemeAccent = "Yellow"
$ThemeMuted = "Gray"
$ThemeError = "Red"
if (Test-Path $ThemePath) {
    $themeData = Get-Content $ThemePath | ConvertFrom-Json
    if ($themeData.colors.primary) { $ThemePrimary = $themeData.colors.primary }
    if ($themeData.colors.secondary) { $ThemeSecondary = $themeData.colors.secondary }
    if ($themeData.colors.accent) { $ThemeAccent = $themeData.colors.accent }
    if ($themeData.colors.muted) { $ThemeMuted = $themeData.colors.muted }
    if ($themeData.colors.error) { $ThemeError = $themeData.colors.error }
}

"""

if "$ThemePath" not in ps1:
    ps1 = ps1.replace('param(', theme_loader + 'param(')

# Replace hardcoded colors with theme variables
ps1 = ps1.replace("-ForegroundColor Magenta", "-ForegroundColor $ThemePrimary")
ps1 = ps1.replace("-ForegroundColor Cyan", "-ForegroundColor $ThemeSecondary")
ps1 = ps1.replace("-ForegroundColor Yellow", "-ForegroundColor $ThemeAccent")
ps1 = ps1.replace("-ForegroundColor DarkGray", "-ForegroundColor $ThemeMuted")
ps1 = ps1.replace("-ForegroundColor Red", "-ForegroundColor $ThemeError")

# The user also wanted to rename Combo Shortcuts to Profiles, and use lowercase slugs instead of titles in the help.
# Wait, let's fix the help menu generation in run.ps1 to use lowercase slugs.
# In run.ps1, the help uses `$printRow "01" "Install VS Code" ...`
# Let's replace those with slugs: "vscode", "nodejs", "pnpm", "python", "golang", "git", "github-desktop", "cpp", "php", etc.
ps1 = ps1.replace('"Install VS Code"', '"vscode"')
ps1 = ps1.replace('"Chocolatey"', '"choco"')
ps1 = ps1.replace('"Node.js + Yarn + Bun"', '"nodejs"')
ps1 = ps1.replace('"Python"', '"python"')
ps1 = ps1.replace('"Python Libraries"', '"pylibs"')
ps1 = ps1.replace('"Golang"', '"golang"')
ps1 = ps1.replace('"Git + LFS + gh"', '"git"')
ps1 = ps1.replace('"GitHub Desktop"', '"github-desktop"')
ps1 = ps1.replace('"C++ (MinGW-w64)"', '"cpp"')
ps1 = ps1.replace('"PHP"', '"php"')
ps1 = ps1.replace('"PowerShell (latest)"', '"pwsh"')
ps1 = ps1.replace('"Flutter + Dart"', '"flutter"')
ps1 = ps1.replace('".NET SDK"', '"dotnet"')
ps1 = ps1.replace('"Java (OpenJDK)"', '"java"')
ps1 = ps1.replace('"VSCode Context Menu Fix"', '"vscode-menu"')
ps1 = ps1.replace('"VSCode Settings Sync"', '"vscode-sync"')
ps1 = ps1.replace('"PowerShell Context Menu"', '"pwsh-menu"')
ps1 = ps1.replace('"Install All Dev Tools"', '"all"')
ps1 = ps1.replace('"Install Databases"', '"databases"')
ps1 = ps1.replace('"Audit Mode"', '"audit"')
ps1 = ps1.replace('"Install Winget"', '"winget"')
ps1 = ps1.replace('"Windows Tweaks"', '"win-tweaks"')
ps1 = ps1.replace('"DBeaver Community"', '"dbeaver"')
ps1 = ps1.replace('"Notepad++ (NPP)"', '"npp"')
ps1 = ps1.replace('"Simple Sticky Notes"', '"sticky-notes"')
ps1 = ps1.replace('"GitMap"', '"gitmap"')
ps1 = ps1.replace('"OBS Studio"', '"obs"')
ps1 = ps1.replace('"Windows Terminal"', '"wt"')

ps1 = ps1.replace('"Combo Shortcuts:"', '"Profiles:"')

with open(run_ps1, "w", encoding="utf-8") as f:
    f.write(ps1)

print("Updated run.ps1 with theme JSON loader and lowercase slugs.")
