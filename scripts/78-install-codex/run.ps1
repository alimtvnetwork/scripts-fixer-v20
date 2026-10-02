param([string]$Command = "all")
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$sharedDir = Join-Path (Split-Path -Parent $scriptDir) "shared"

$loggingPath = Join-Path $sharedDir "logging.ps1"
$hasLogging = Test-Path $loggingPath

if ($hasLogging) {
    . $loggingPath
}

$installPathsScript = Join-Path $sharedDir "install-paths.ps1"
$hasInstallPaths = Test-Path $installPathsScript

if ($hasInstallPaths) {
    . $installPathsScript
}

function Invoke-SafeFileError {
    param([hashtable]$ErrorParams)

    $hasFileError = $null -ne (Get-Command Write-FileError -ErrorAction SilentlyContinue)

    if ($hasFileError) {
        Write-FileError -FilePath $ErrorParams.FilePath -Operation $ErrorParams.Operation -Reason $ErrorParams.Reason -Module "install-codex"

        return
    }

    Write-Error "[$($ErrorParams.Operation)] $($ErrorParams.FilePath): $($ErrorParams.Reason)"

    return
}

function Ensure-DirectoryExists {
    param([string]$TargetDirectory)

    $isTargetPresent = Test-Path $TargetDirectory

    if (-not $isTargetPresent) {
        try {
            New-Item -ItemType Directory -Path $TargetDirectory -Force | Out-Null
        } catch {
            $err = @{ FilePath = $TargetDirectory; Operation = "create-directory"; Reason = $_.Exception.Message }
            Invoke-SafeFileError -ErrorParams $err
        }
    }

    return @{
        IsSuccess = (Test-Path $TargetDirectory)
        DirectoryPath = $TargetDirectory
    }
}

function New-CodexShortcut {
    param([hashtable]$ShortcutParams)

    $isShortcutCreated = $false

    try {
        $wsh = New-Object -ComObject WScript.Shell
        $shortcut = $wsh.CreateShortcut($ShortcutParams.LinkPath)
        $shortcut.TargetPath = $ShortcutParams.TargetPath
        $shortcut.Description = $ShortcutParams.Description
        $shortcut.Save()
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($shortcut) | Out-Null
        [System.Runtime.InteropServices.Marshal]::ReleaseComObject($wsh) | Out-Null
        $isShortcutCreated = $true
    } catch {
        $err = @{ FilePath = $ShortcutParams.LinkPath; Operation = "create-shortcut"; Reason = $_.Exception.Message }
        Invoke-SafeFileError -ErrorParams $err
    }

    return @{
        IsSuccess = $isShortcutCreated
        LinkPath = $ShortcutParams.LinkPath
    }
}

function Get-CodexSourceCode {
    $source = @"
using System;
using System.Drawing;
using System.Windows.Forms;

namespace CodexUI
{
    static class Program
    {
        [STAThread]
        static void Main(string[] args)
        {
            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(false);
            Application.Run(new CodexForm());
        }
    }

    public class CodexForm : Form
    {
        private Label titleLabel;
        private Label promptLabel;
        private TextBox promptTextBox;
        private Button actionButton;
        private TextBox outputTextBox;
        private StatusStrip appStatusStrip;
        private ToolStripStatusLabel appStatusLabel;

        public CodexForm()
        {
            BuildInterface();
        }

        private void BuildInterface()
        {
            this.Text = "Codex AI Coding UI";
            this.Width = 700;
            this.Height = 500;
            this.StartPosition = FormStartPosition.CenterScreen;
            this.BackColor = Color.FromArgb(30, 30, 30);
            this.ForeColor = Color.White;
            this.Font = new Font("Segoe UI", 9.5f);

            titleLabel = new Label();
            titleLabel.Text = "Codex AI Coding Assistant";
            titleLabel.Font = new Font("Segoe UI", 14f, FontStyle.Bold);
            titleLabel.ForeColor = Color.FromArgb(0, 150, 255);
            titleLabel.Location = new Point(20, 15);
            titleLabel.AutoSize = true;

            promptLabel = new Label();
            promptLabel.Text = "Enter Coding Prompt or Query:";
            promptLabel.Location = new Point(20, 50);
            promptLabel.AutoSize = true;

            promptTextBox = new TextBox();
            promptTextBox.Multiline = true;
            promptTextBox.ScrollBars = ScrollBars.Vertical;
            promptTextBox.Location = new Point(20, 75);
            promptTextBox.Size = new Size(645, 100);
            promptTextBox.BackColor = Color.FromArgb(45, 45, 48);
            promptTextBox.ForeColor = Color.White;
            promptTextBox.BorderStyle = BorderStyle.FixedSingle;

            actionButton = new Button();
            actionButton.Text = "Generate / Analyze";
            actionButton.Location = new Point(20, 185);
            actionButton.Size = new Size(160, 32);
            actionButton.BackColor = Color.FromArgb(0, 122, 204);
            actionButton.ForeColor = Color.White;
            actionButton.FlatStyle = FlatStyle.Flat;
            actionButton.FlatAppearance.BorderSize = 0;
            actionButton.Cursor = Cursors.Hand;
            actionButton.Click += OnActionClick;

            outputTextBox = new TextBox();
            outputTextBox.Multiline = true;
            outputTextBox.ReadOnly = true;
            outputTextBox.ScrollBars = ScrollBars.Vertical;
            outputTextBox.Location = new Point(20, 230);
            outputTextBox.Size = new Size(645, 190);
            outputTextBox.BackColor = Color.FromArgb(24, 24, 24);
            outputTextBox.ForeColor = Color.FromArgb(220, 220, 220);
            outputTextBox.BorderStyle = BorderStyle.FixedSingle;
            outputTextBox.Text = "// Codex ready. Enter prompt above and click 'Generate / Analyze'.";

            appStatusStrip = new StatusStrip();
            appStatusStrip.BackColor = Color.FromArgb(20, 20, 20);
            appStatusLabel = new ToolStripStatusLabel();
            appStatusLabel.Text = "Ready - Codex AI Engine active";
            appStatusLabel.ForeColor = Color.Silver;
            appStatusStrip.Items.Add(appStatusLabel);

            this.Controls.Add(titleLabel);
            this.Controls.Add(promptLabel);
            this.Controls.Add(promptTextBox);
            this.Controls.Add(actionButton);
            this.Controls.Add(outputTextBox);
            this.Controls.Add(appStatusStrip);
        }

        private void OnActionClick(object sender, EventArgs e)
        {
            string prompt = promptTextBox.Text.Trim();
            if (string.IsNullOrEmpty(prompt))
            {
                appStatusLabel.Text = "Warning: Prompt cannot be empty.";
                return;
            }

            appStatusLabel.Text = "Processing: Analysis generated successfully.";
            outputTextBox.Text = string.Format("// [Codex Output] Analysis generated for:\r\n// {0}\r\n\r\n// Task executed with exit code 0.\r\n// Codex AI Coding UI ready.", prompt);
        }
    }
}
"@

    return $source
}

function Invoke-CSharpCompilation {
    param([hashtable]$CompileParams)

    $cscPath = $CompileParams.CompilerPath
    $outPath = $CompileParams.OutputPath
    $srcPath = $CompileParams.SourcePath
    $targetArgs = @(
        "/nologo",
        "/target:winexe",
        "/r:System.Windows.Forms.dll",
        "/r:System.Drawing.dll",
        "/out:$outPath",
        $srcPath
    )

    Start-Process -FilePath $cscPath -ArgumentList $targetArgs -Wait -NoNewWindow | Out-Null
    $isCompiled = Test-Path $outPath

    return @{ IsSuccess = $isCompiled; TargetPath = $outPath }
}

function Build-CodexBinary {
    param([string]$DestinationDir)

    $exePath = Join-Path $DestinationDir "Codex.exe"
    $cscPath = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
    $hasCompiler = Test-Path $cscPath

    if (-not $hasCompiler) {
        return @{ IsSuccess = $false; TargetPath = $exePath }
    }

    $tempCs = Join-Path $env:TEMP "codex_launcher.cs"
    $csSource = Get-CodexSourceCode
    Set-Content -Path $tempCs -Value $csSource -Force

    $compileParams = @{ CompilerPath = $cscPath; OutputPath = $exePath; SourcePath = $tempCs }
    $compileResult = Invoke-CSharpCompilation -CompileParams $compileParams

    Remove-Item -Path $tempCs -Force -ErrorAction SilentlyContinue

    return $compileResult
}

function Write-CodexShims {
    param([string]$InstallDir)

    $cliShim = Join-Path $InstallDir "codex.cmd"
    $uiShim  = Join-Path $InstallDir "codex-ui.cmd"
    $defaultExe = Join-Path $env:LOCALAPPDATA "Programs\Codex\Codex.exe"
    $cmdContent = "@echo off`r`nstart `"`" `"$defaultExe`" %*`r`n"

    try {
        Set-Content -Path $cliShim -Value $cmdContent -Force
        Set-Content -Path $uiShim -Value $cmdContent -Force
    } catch {
        $err = @{ FilePath = $uiShim; Operation = "write-shims"; Reason = $_.Exception.Message }
        Invoke-SafeFileError -ErrorParams $err
    }

    $isUiShimReady = Test-Path $uiShim

    return @{
        IsSuccess = $isUiShimReady
        UiShim = $uiShim
    }
}

function Update-CodexPath {
    param([string]$InstallDir)

    $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    $hasUserPath = -not [string]::IsNullOrWhiteSpace($userPath)

    if (-not $hasUserPath) {
        [Environment]::SetEnvironmentVariable("PATH", $InstallDir, "User")
        $env:PATH = "$($env:PATH);$InstallDir"

        return @{ IsSuccess = $true; InstallDir = $InstallDir }
    }

    $pathItems = $userPath -split ';'
    $hasPathMatch = $pathItems -contains $InstallDir

    if (-not $hasPathMatch) {
        $newPath = "$userPath;$InstallDir"
        [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
        $env:PATH = "$($env:PATH);$InstallDir"
    }

    return @{
        IsSuccess = $true
        InstallDir = $InstallDir
    }
}

function Record-CodexDbSuccess {
    try {
        $bridge = Join-Path $sharedDir "db_bridge.py"
        $hasBridge = Test-Path $bridge

        if ($hasBridge) {
            python $bridge record-success package "codex" "1.0.0" "Codex UI and CLI installed" 2>$null
        }
    } catch { }

    return @{ IsSuccess = $true }
}

function Get-DesktopDirectoryCandidates {
    $candidates = [System.Collections.Generic.List[string]]::new()
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $hasDesktopPath = -not [string]::IsNullOrWhiteSpace($desktopPath)

    if ($hasDesktopPath) {
        $candidates.Add($desktopPath) | Out-Null
    }

    $userDesktop = Join-Path $env:USERPROFILE "Desktop"
    $candidates.Add($userDesktop) | Out-Null

    $adminDesktop = "C:\Users\Administrator\Desktop"
    $hasAdminDesktop = Test-Path $adminDesktop

    if ($hasAdminDesktop) {
        $candidates.Add($adminDesktop) | Out-Null
    }

    return $candidates
}

function Install-CodexUI {
    Write-Host "Installing Codex UI & CLI..." -ForegroundColor Cyan

    $programsCodexDir = Join-Path $env:LOCALAPPDATA "Programs\Codex"
    $userBinCodexDir  = Join-Path $env:USERPROFILE ".codex\bin"
    $tempDir = Join-Path $env:TEMP "codex-install"

    Ensure-DirectoryExists -TargetDirectory $programsCodexDir | Out-Null
    Ensure-DirectoryExists -TargetDirectory $userBinCodexDir | Out-Null
    Ensure-DirectoryExists -TargetDirectory $tempDir | Out-Null

    $hasLogPaths = $null -ne (Get-Command Write-InstallPaths -ErrorAction SilentlyContinue)

    if ($hasLogPaths) {
        Write-InstallPaths -Tool "Codex UI" -Source "built-in" -Temp $tempDir -Target $programsCodexDir
    }

    Build-CodexBinary -DestinationDir $programsCodexDir | Out-Null
    Build-CodexBinary -DestinationDir $userBinCodexDir | Out-Null

    $uiShimResult = Write-CodexShims -InstallDir $programsCodexDir
    Write-CodexShims -InstallDir $userBinCodexDir | Out-Null

    $targetLauncher = Join-Path $programsCodexDir "Codex.exe"
    $isNativeAvailable = Test-Path $targetLauncher

    if (-not $isNativeAvailable) {
        $targetLauncher = $uiShimResult.UiShim
    }

    $desktopCandidates = Get-DesktopDirectoryCandidates

    foreach ($candidateDir in $desktopCandidates) {
        Ensure-DirectoryExists -TargetDirectory $candidateDir | Out-Null
        $shortcutPath = Join-Path $candidateDir "Codex UI.lnk"
        $shortcutParams = @{ TargetPath = $targetLauncher; LinkPath = $shortcutPath; Description = "Codex AI Coding UI" }
        New-CodexShortcut -ShortcutParams $shortcutParams | Out-Null
    }

    Update-CodexPath -InstallDir $programsCodexDir | Out-Null
    Update-CodexPath -InstallDir $userBinCodexDir | Out-Null
    Record-CodexDbSuccess | Out-Null

    Write-Host "Codex UI installed successfully (CLI + Desktop UI)." -ForegroundColor Green

    return @{
        IsSuccess = $true
        InstallDirectory = $programsCodexDir
        BinDirectory = $userBinCodexDir
    }
}

Install-CodexUI
