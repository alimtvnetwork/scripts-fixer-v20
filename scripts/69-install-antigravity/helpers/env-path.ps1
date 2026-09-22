<#
.SYNOPSIS
    Environment and PATH management for Antigravity.
#>

function Broadcast-EnvironmentChange {
    try {
        $typeName = 'AntigravityNativeMethods'
        $hasType = [bool]([System.Management.Automation.PSTypeName]$typeName).Type

        if (-not $hasType) {
            $typeDef = @"
using System;
using System.Runtime.InteropServices;
public static class AntigravityNativeMethods {
    public const int HWND_BROADCAST = 0xffff;
    public const int WM_SETTINGCHANGE = 0x1A;
    public const int SMTO_ABORTIFHUNG = 0x2;
    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    public static extern IntPtr SendMessageTimeout(
        IntPtr hWnd, int Msg, IntPtr wParam, string lParam,
        int fuFlags, int uTimeout, out IntPtr lpdwResult);
}
"@
            Add-Type -TypeDefinition $typeDef -ErrorAction SilentlyContinue | Out-Null
        }

        $result = [IntPtr]::Zero
        [void][AntigravityNativeMethods]::SendMessageTimeout(
            [IntPtr]0xffff,
            0x1A,
            [IntPtr]::Zero,
            "Environment",
            0x2,
            3000,
            [ref]$result
        )
    } catch { }
}

function Update-UserPath {
    param([string]$InstallDir)

    $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    if ($null -eq $userPath) {
        $userPath = ""
    }

    $pathParts = $userPath -split ';' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    $hasDir = $pathParts -contains $InstallDir

    if (-not $hasDir) {
        $newUserPath = ($pathParts + $InstallDir) -join ';'
        [Environment]::SetEnvironmentVariable("PATH", $newUserPath, "User")
        Write-Host "Added $InstallDir to User PATH." -ForegroundColor Cyan
    }
}

function Update-ProcessPath {
    param([string]$InstallDir)

    $procParts = $env:PATH -split ';' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
    $hasDir = $procParts -contains $InstallDir

    if (-not $hasDir) {
        $env:PATH = ($procParts + $InstallDir) -join ';'
    }
}

function Update-EnvironmentPath {
    param([Parameter(Mandatory = $true)][string]$InstallDir)

    Update-UserPath -InstallDir $InstallDir
    Update-ProcessPath -InstallDir $InstallDir
    Broadcast-EnvironmentChange
}
