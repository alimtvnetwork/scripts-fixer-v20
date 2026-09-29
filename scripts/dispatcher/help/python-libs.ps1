# Python and pip libraries cheatsheet help

function Show-HelpPythonQuickAndPurpose {
    Write-Host "    Python & pip libraries:" -ForegroundColor $ThemePrimary
    Write-Host ""
    Write-Host "      Quick install:" -ForegroundColor DarkYellow

    Write-HelpKeywordLine "install pylibs" "Install Python + all libraries in one go"
    Write-HelpKeywordLine "install python-libs" "Install all pip libraries only (numpy, pandas, etc.)"
    Write-HelpKeywordLine "install python+libs" "Install Python + all libraries in one go"

    Write-Host ""
    Write-Host "      By purpose:" -ForegroundColor DarkYellow
    Write-HelpKeywordLine "install data-science" "Python + data/viz libs (pandas, matplotlib, plotly)"
    Write-HelpKeywordLine "install ai-dev" "Python + ML libs (numpy, scipy, scikit-learn, torch)"
    Write-HelpKeywordLine "install deep-learning" "Python + ML libs (same as ai-dev)"
    Write-HelpKeywordLine "install jupyter+libs" "Jupyter only (jupyterlab, notebook, ipykernel)"
    Write-HelpKeywordLine "install viz-libs" "Visualization (matplotlib, seaborn, plotly)"
    Write-HelpKeywordLine "install web-libs" "Web frameworks (django, flask, fastapi, uvicorn)"
    Write-HelpKeywordLine "install scraping-libs" "Scraping (requests, beautifulsoup4)"
    Write-HelpKeywordLine "install db-libs" "Database (sqlalchemy)"
    Write-HelpKeywordLine "install cv-libs" "Computer Vision (opencv-python)"
    Write-HelpKeywordLine "install data-libs" "Data tools (pandas, polars)"
    Write-Host ""
}

function Show-HelpPythonGroupsAndUtils {
    Write-Host "      With Python (auto-installs Python first):" -ForegroundColor DarkYellow
    Write-HelpKeywordLine "install python+viz" "Python + visualization group"
    Write-HelpKeywordLine "install python+web" "Python + web frameworks group"
    Write-HelpKeywordLine "install python+scraping" "Python + scraping group"
    Write-HelpKeywordLine "install python+db" "Python + database group"
    Write-HelpKeywordLine "install python+cv" "Python + computer vision group"
    Write-HelpKeywordLine "install python+data" "Python + data tools group"
    Write-HelpKeywordLine "install python+ml" "Python + ML group"
    Write-HelpKeywordLine "install python+jupyter" "Python + all libraries (includes Jupyter)"

    Write-Host ""
    Write-Host "      By group (.\run.ps1 -I 41 --):" -ForegroundColor DarkYellow
    Write-HelpKeywordLine ".\run.ps1 -I 41 -- group ml" "ML group (numpy, scipy, scikit-learn, torch...)"
    Write-HelpKeywordLine ".\run.ps1 -I 41 -- group jupyter" "Jupyter (jupyterlab, notebook, ipykernel, ipywidgets)"
    Write-HelpKeywordLine ".\run.ps1 -I 41 -- group viz" "Visualization (matplotlib, seaborn, plotly)"
    Write-HelpKeywordLine ".\run.ps1 -I 41 -- group data" "Data tools (pandas, polars)"
    Write-HelpKeywordLine ".\run.ps1 -I 41 -- group web" "Web frameworks (django, flask, fastapi, uvicorn)"
    Write-HelpKeywordLine ".\run.ps1 -I 41 -- group scraping" "Scraping (requests, beautifulsoup4)"
    Write-HelpKeywordLine ".\run.ps1 -I 41 -- group cv" "Computer Vision (opencv-python)"
    Write-HelpKeywordLine ".\run.ps1 -I 41 -- group db" "Database (sqlalchemy)"

    Write-Host ""
    Write-Host "      Utilities:" -ForegroundColor DarkYellow
    Write-HelpKeywordLine ".\run.ps1 -I 41 -- add <pkg1> <pkg2>" "Install specific packages by name"
    Write-HelpKeywordLine ".\run.ps1 -I 41 -- list" "Show all available library groups"
    Write-HelpKeywordLine ".\run.ps1 -I 41 -- installed" "Show currently installed pip packages"
    Write-HelpKeywordLine ".\run.ps1 -I 41 -- uninstall" "Uninstall all tracked libraries"
    Write-HelpKeywordLine ".\run.ps1 -I 41 -- uninstall <pkg>" "Uninstall specific packages"
    Write-Host ""
}

function Show-HelpPythonLibs {
    Show-HelpPythonQuickAndPurpose
    Show-HelpPythonGroupsAndUtils
}
