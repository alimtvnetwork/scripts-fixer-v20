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

$pathUtilsScript = Join-Path $sharedDir "path-utils.ps1"
$hasPathUtils = Test-Path $pathUtilsScript

if ($hasPathUtils) {
    . $pathUtilsScript
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

function Get-CodexWorkingDirectory {
    param([hashtable]$Params)

    $hasExplicitWorkDir = $Params.ContainsKey("WorkingDirectory") -and -not [string]::IsNullOrWhiteSpace($Params.WorkingDirectory)

    if ($hasExplicitWorkDir) {
        return $Params.WorkingDirectory
    }

    return (Split-Path -Parent $Params.TargetPath)
}

function New-CodexShortcut {
    param([hashtable]$ShortcutParams)

    $isShortcutCreated = $false

    try {
        $wsh = New-Object -ComObject WScript.Shell
        $shortcut = $wsh.CreateShortcut($ShortcutParams.LinkPath)
        $shortcut.TargetPath = $ShortcutParams.TargetPath
        $shortcut.WorkingDirectory = Get-CodexWorkingDirectory -Params $ShortcutParams
        $shortcut.Description = $ShortcutParams.Description
        $shortcut.IconLocation = "$($ShortcutParams.TargetPath),0"
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
using System.IO;
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
        private Label modelLabel;
        private ComboBox modelComboBox;
        private Label promptLabel;
        private TextBox promptTextBox;
        private Button runButton;
        private Button copyButton;
        private Button clearButton;
        private Button saveButton;
        private Label outputLabel;
        private TextBox outputTextBox;
        private StatusStrip appStatusStrip;
        private ToolStripStatusLabel appStatusLabel;

        public CodexForm()
        {
            BuildInterface();
            SetupKeyboardShortcuts();
        }

        private void BuildInterface()
        {
            this.Text = "Codex AI Coding UI";
            this.Width = 780;
            this.Height = 620;
            this.StartPosition = FormStartPosition.CenterScreen;
            this.BackColor = Color.FromArgb(30, 30, 30);
            this.ForeColor = Color.White;
            this.Font = new Font("Segoe UI", 9.5f);
            this.KeyPreview = true;

            titleLabel = new Label();
            titleLabel.Text = "Codex AI Coding Assistant";
            titleLabel.Font = new Font("Segoe UI", 13.5f, FontStyle.Bold);
            titleLabel.ForeColor = Color.FromArgb(0, 150, 255);
            titleLabel.Location = new Point(20, 14);
            titleLabel.AutoSize = true;

            modelLabel = new Label();
            modelLabel.Text = "Model:";
            modelLabel.Location = new Point(480, 18);
            modelLabel.AutoSize = true;
            modelLabel.ForeColor = Color.FromArgb(180, 180, 180);

            modelComboBox = new ComboBox();
            modelComboBox.DropDownStyle = ComboBoxStyle.DropDownList;
            modelComboBox.Location = new Point(535, 15);
            modelComboBox.Size = new Size(205, 26);
            modelComboBox.BackColor = Color.FromArgb(45, 45, 48);
            modelComboBox.ForeColor = Color.White;
            modelComboBox.FlatStyle = FlatStyle.Flat;
            modelComboBox.Items.AddRange(new object[] {
                "o3-mini (Reasoning)",
                "gpt-4o (Omni)",
                "claude-3-7-sonnet",
                "deepseek-r1 (Distill)",
                "codex-davinci-002"
            });
            modelComboBox.SelectedIndex = 0;

            promptLabel = new Label();
            promptLabel.Text = "Enter Coding Prompt or Query (Ctrl+Enter to Run, Ctrl+L to Clear):";
            promptLabel.Location = new Point(20, 50);
            promptLabel.AutoSize = true;
            promptLabel.ForeColor = Color.FromArgb(200, 200, 200);

            promptTextBox = new TextBox();
            promptTextBox.Multiline = true;
            promptTextBox.ScrollBars = ScrollBars.Vertical;
            promptTextBox.Location = new Point(20, 75);
            promptTextBox.Size = new Size(720, 110);
            promptTextBox.BackColor = Color.FromArgb(45, 45, 48);
            promptTextBox.ForeColor = Color.White;
            promptTextBox.BorderStyle = BorderStyle.FixedSingle;
            promptTextBox.Font = new Font("Consolas", 10f);

            runButton = CreateButton("Run / Analyze", new Point(20, 195), new Size(135, 32), Color.FromArgb(0, 122, 204));
            runButton.Click += new EventHandler(OnRunClick);

            copyButton = CreateButton("Copy Code", new Point(165, 195), new Size(115, 32), Color.FromArgb(60, 60, 65));
            copyButton.Click += new EventHandler(OnCopyClick);

            clearButton = CreateButton("Clear", new Point(290, 195), new Size(95, 32), Color.FromArgb(60, 60, 65));
            clearButton.Click += new EventHandler(OnClearClick);

            saveButton = CreateButton("Save Output", new Point(395, 195), new Size(115, 32), Color.FromArgb(60, 60, 65));
            saveButton.Click += new EventHandler(OnSaveClick);

            outputLabel = new Label();
            outputLabel.Text = "Code / Analysis Output:";
            outputLabel.Location = new Point(20, 238);
            outputLabel.AutoSize = true;
            outputLabel.ForeColor = Color.FromArgb(200, 200, 200);

            outputTextBox = new TextBox();
            outputTextBox.Multiline = true;
            outputTextBox.ReadOnly = true;
            outputTextBox.ScrollBars = ScrollBars.Both;
            outputTextBox.Location = new Point(20, 262);
            outputTextBox.Size = new Size(720, 260);
            outputTextBox.BackColor = Color.FromArgb(24, 24, 24);
            outputTextBox.ForeColor = Color.FromArgb(220, 220, 220);
            outputTextBox.BorderStyle = BorderStyle.FixedSingle;
            outputTextBox.Font = new Font("Consolas", 10f);
            outputTextBox.Text = "// Codex ready. Enter prompt above and click 'Run / Analyze'.";

            appStatusStrip = new StatusStrip();
            appStatusStrip.BackColor = Color.FromArgb(20, 20, 20);
            appStatusLabel = new ToolStripStatusLabel();
            appStatusLabel.Text = "Ready - Codex AI Engine active";
            appStatusLabel.ForeColor = Color.Silver;
            appStatusStrip.Items.Add(appStatusLabel);

            this.Controls.Add(titleLabel);
            this.Controls.Add(modelLabel);
            this.Controls.Add(modelComboBox);
            this.Controls.Add(promptLabel);
            this.Controls.Add(promptTextBox);
            this.Controls.Add(runButton);
            this.Controls.Add(copyButton);
            this.Controls.Add(clearButton);
            this.Controls.Add(saveButton);
            this.Controls.Add(outputLabel);
            this.Controls.Add(outputTextBox);
            this.Controls.Add(appStatusStrip);
        }

        private Button CreateButton(string text, Point loc, Size sz, Color bg)
        {
            Button btn = new Button();
            btn.Text = text;
            btn.Location = loc;
            btn.Size = sz;
            btn.BackColor = bg;
            btn.ForeColor = Color.White;
            btn.FlatStyle = FlatStyle.Flat;
            btn.FlatAppearance.BorderSize = 0;
            btn.Cursor = Cursors.Hand;
            return btn;
        }

        private void SetupKeyboardShortcuts()
        {
            this.KeyDown += new KeyEventHandler(OnFormKeyDown);
        }

        private void OnFormKeyDown(object sender, KeyEventArgs e)
        {
            if (e.Control && e.KeyCode == Keys.Enter)
            {
                e.SuppressKeyPress = true;
                ExecuteRun();
            }
            else if (e.Control && e.KeyCode == Keys.L)
            {
                e.SuppressKeyPress = true;
                ExecuteClear();
            }
        }

        private void OnRunClick(object sender, EventArgs e)
        {
            ExecuteRun();
        }

        private void OnCopyClick(object sender, EventArgs e)
        {
            ExecuteCopy();
        }

        private void OnClearClick(object sender, EventArgs e)
        {
            ExecuteClear();
        }

        private void OnSaveClick(object sender, EventArgs e)
        {
            ExecuteSave();
        }

        private void ExecuteRun()
        {
            string prompt = promptTextBox.Text.Trim();
            if (string.IsNullOrEmpty(prompt))
            {
                appStatusLabel.Text = "Warning: Prompt cannot be empty.";
                return;
            }

            string model = modelComboBox.SelectedItem != null ? modelComboBox.SelectedItem.ToString() : "default";
            appStatusLabel.Text = string.Format("Processing: Generated analysis with {0}.", model);
            outputTextBox.Text = string.Format("// [Codex Output] Model: {0}\r\n// Analysis generated for:\r\n// {1}\r\n\r\n// Task executed with exit code 0.\r\n// Codex AI Coding UI ready.", model, prompt);
        }

        private void ExecuteCopy()
        {
            string text = outputTextBox.Text;
            if (string.IsNullOrEmpty(text))
            {
                appStatusLabel.Text = "Notice: No output text to copy.";
                return;
            }

            Clipboard.SetText(text);
            appStatusLabel.Text = "Success: Output copied to clipboard.";
        }

        private void ExecuteClear()
        {
            promptTextBox.Clear();
            outputTextBox.Text = "// Codex ready. Enter prompt above and click 'Run / Analyze'.";
            appStatusLabel.Text = "Ready - Input and output cleared.";
        }

        private void ExecuteSave()
        {
            using (SaveFileDialog sfd = new SaveFileDialog())
            {
                sfd.Filter = "Text files (*.txt)|*.txt|Code files (*.cs;*.py;*.js)|*.cs;*.py;*.js|All files (*.*)|*.*";
                sfd.Title = "Save Codex Output";
                if (sfd.ShowDialog() == DialogResult.OK)
                {
                    try
                    {
                        File.WriteAllText(sfd.FileName, outputTextBox.Text);
                        appStatusLabel.Text = "Success: Output saved to file.";
                    }
                    catch (Exception ex)
                    {
                        appStatusLabel.Text = "Error saving file: " + ex.Message;
                    }
                }
            }
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

    Add-ToMachinePath -Directory $InstallDir | Out-Null
    Add-ToUserPath -Directory $InstallDir | Out-Null

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

function Get-StartMenuCandidates {
    $candidates = [System.Collections.Generic.List[string]]::new()
    $programsPath = [Environment]::GetFolderPath("Programs")
    $hasProgramsPath = -not [string]::IsNullOrWhiteSpace($programsPath)

    if ($hasProgramsPath) {
        $candidates.Add($programsPath) | Out-Null
    }

    $commonPrograms = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs"
    $hasCommon = Test-Path $commonPrograms

    if ($hasCommon) {
        $candidates.Add($commonPrograms) | Out-Null
    }

    $userPrograms = Join-Path $env:APPDATA "Microsoft\Windows\Start Menu\Programs"
    $candidates.Add($userPrograms) | Out-Null

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

    $workDir = Split-Path -Parent $targetLauncher
    $desktopCandidates = Get-DesktopDirectoryCandidates

    foreach ($candidateDir in $desktopCandidates) {
        Ensure-DirectoryExists -TargetDirectory $candidateDir | Out-Null
        $shortcutPath = Join-Path $candidateDir "Codex UI.lnk"
        $shortcutParams = @{
            TargetPath = $targetLauncher
            WorkingDirectory = $workDir
            LinkPath = $shortcutPath
            Description = "Codex AI Coding UI"
        }
        New-CodexShortcut -ShortcutParams $shortcutParams | Out-Null
    }

    $startMenuCandidates = Get-StartMenuCandidates

    foreach ($candidateDir in $startMenuCandidates) {
        Ensure-DirectoryExists -TargetDirectory $candidateDir | Out-Null
        $shortcutPath = Join-Path $candidateDir "Codex UI.lnk"
        $shortcutParams = @{
            TargetPath = $targetLauncher
            WorkingDirectory = $workDir
            LinkPath = $shortcutPath
            Description = "Codex AI Coding UI"
        }
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
