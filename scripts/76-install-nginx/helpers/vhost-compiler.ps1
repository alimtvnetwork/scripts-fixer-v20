# --------------------------------------------------------------------------
#  Helper: Vhost Compiler for Windows Nginx Domain Manager
#  Handles template compilation, path forward-slash normalization,
#  conf.d inclusion assurance, and nginx -t syntax gating.
# --------------------------------------------------------------------------

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Normalize-NginxPath {
    param([string]$Path)
    if ([string]::IsNullOrWhiteSpace($Path)) { return "" }
    return $Path.Replace("\", "/")
}

function Get-NginxVhostDir {
    param([string]$NginxExe = "")
    if ([string]::IsNullOrWhiteSpace($NginxExe)) {
        if (Get-Command Find-NginxExe -ErrorAction SilentlyContinue) {
            $NginxExe = Find-NginxExe
        }
    }
    if ([string]::IsNullOrWhiteSpace($NginxExe)) {
        $defaultDir = "C:\tools\nginx"
        $vhostDir = Join-Path $defaultDir "conf\conf.d"
        return $vhostDir
    }

    $nginxRoot = Split-Path -Parent $NginxExe
    $vhostDir = Join-Path $nginxRoot "conf\conf.d"
    return $vhostDir
}

function Ensure-NginxConfIncludes {
    param([string]$NginxExe = "")
    if ([string]::IsNullOrWhiteSpace($NginxExe)) {
        if (Get-Command Find-NginxExe -ErrorAction SilentlyContinue) {
            $NginxExe = Find-NginxExe
        }
    }
    if ([string]::IsNullOrWhiteSpace($NginxExe)) { return }

    $nginxRoot = Split-Path -Parent $NginxExe
    $confFile = Join-Path $nginxRoot "conf\nginx.conf"
    if (-not (Test-Path -LiteralPath $confFile)) { return }

    $content = Get-Content -LiteralPath $confFile -Raw
    if ($content -match 'include\s+conf\.d/\*\.conf;') {
        return
    }

    # Inject include conf.d/*.conf; inside http { } block
    if ($content -match 'http\s*\{') {
        $replacement = "http {`n    include conf.d/*.conf;"
        $newContent = [regex]::Replace($content, 'http\s*\{', $replacement, 1)
        [System.IO.File]::WriteAllText($confFile, $newContent, (New-Object System.Text.UTF8Encoding($false)))
    }
}

function Test-NginxSyntax {
    param([string]$NginxExe = "")
    if ([string]::IsNullOrWhiteSpace($NginxExe)) {
        if (Get-Command Find-NginxExe -ErrorAction SilentlyContinue) {
            $NginxExe = Find-NginxExe
        }
    }
    if ([string]::IsNullOrWhiteSpace($NginxExe)) {
        # If Nginx is not installed yet, syntax check passes hypothetically
        return $true
    }

    $nginxRoot = Split-Path -Parent $NginxExe
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $NginxExe
    $psi.Arguments = "-t"
    $psi.WorkingDirectory = $nginxRoot
    $psi.RedirectStandardError = $true
    $psi.RedirectStandardOutput = $true
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true

    $proc = [System.Diagnostics.Process]::Start($psi)
    $stderr = $proc.StandardError.ReadToEnd()
    $stdout = $proc.StandardOutput.ReadToEnd()
    $proc.WaitForExit()

    $isOk = ($proc.ExitCode -eq 0)
    return $isOk
}

function Build-NginxVhostConfig {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Domain,

        [string]$Type = "static",
        [int]$Port = 80,
        [string]$RootPath = "",
        [string]$PhpSocket = "127.0.0.1:9000",
        [string]$ProxyPass = "",
        [int]$SslEnabled = 0
    )

    $templatesDir = Join-Path (Split-Path -Parent $PSScriptRoot) "templates"
    $templateFile = Join-Path $templatesDir "$Type.conf.template"
    if (-not (Test-Path -LiteralPath $templateFile)) {
        $templateFile = Join-Path $templatesDir "static.conf.template"
    }

    $templateContent = Get-Content -LiteralPath $templateFile -Raw

    $normRoot = Normalize-NginxPath $RootPath
    if ([string]::IsNullOrWhiteSpace($normRoot)) {
        $normRoot = "C:/tools/nginx/html/$Domain"
    }

    $rendered = $templateContent `
        -replace '\{\{DOMAIN\}\}', $Domain `
        -replace '\{\{PORT\}\}', $Port.ToString() `
        -replace '\{\{ROOT\}\}', $normRoot `
        -replace '\{\{PHP_SOCKET\}\}', $PhpSocket `
        -replace '\{\{PROXY_PASS\}\}', $ProxyPass

    return $rendered
}

function Save-NginxVhostConfig {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Domain,

        [Parameter(Mandatory = $true)]
        [string]$ConfigContent,

        [string]$NginxExe = ""
    )

    $vhostDir = Get-NginxVhostDir -NginxExe $NginxExe
    if (-not (Test-Path -LiteralPath $vhostDir)) {
        New-Item -ItemType Directory -Path $vhostDir -Force | Out-Null
    }

    Ensure-NginxConfIncludes -NginxExe $NginxExe

    $confFile = Join-Path $vhostDir "$Domain.conf"
    $backupFile = Join-Path $vhostDir "$Domain.conf.bak"

    if (Test-Path -LiteralPath $confFile) {
        Copy-Item -LiteralPath $confFile -Destination $backupFile -Force
    }

    [System.IO.File]::WriteAllText($confFile, $ConfigContent, (New-Object System.Text.UTF8Encoding($false)))

    # Syntax test
    $isValid = Test-NginxSyntax -NginxExe $NginxExe
    if (-not $isValid) {
        # Restore backup if available, or remove invalid conf
        if (Test-Path -LiteralPath $backupFile) {
            Move-Item -LiteralPath $backupFile -Destination $confFile -Force
        } else {
            Remove-Item -LiteralPath $confFile -Force
        }
        throw "Nginx configuration syntax test (-t) failed for $Domain. Changes were reverted."
    }

    if (Test-Path -LiteralPath $backupFile) {
        Remove-Item -LiteralPath $backupFile -Force
    }

    return $confFile
}

function Remove-NginxVhostConfig {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Domain,

        [string]$NginxExe = "",
        [switch]$Purge
    )

    $vhostDir = Get-NginxVhostDir -NginxExe $NginxExe
    $confFile = Join-Path $vhostDir "$Domain.conf"

    if (-not (Test-Path -LiteralPath $confFile)) {
        return $false
    }

    if ($Purge) {
        Remove-Item -LiteralPath $confFile -Force
    } else {
        $bakFile = Join-Path $vhostDir "$Domain.conf.disabled"
        Move-Item -LiteralPath $confFile -Destination $bakFile -Force
    }

    return $true
}
