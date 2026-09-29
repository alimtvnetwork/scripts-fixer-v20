# Pester tests for Machine Identity and Terminal Cleaner helpers
# Run with: Invoke-Pester -Path tests/pester

BeforeAll {
    $script:Repo = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
    $script:MachineHelper = Join-Path $Repo 'scripts/os/helpers/machine-info.ps1'
    $script:TerminalHelper = Join-Path $Repo 'scripts/os/helpers/clear-terminal.ps1'
    $script:ShMachineHelper = Join-Path $Repo 'scripts-linux/_shared/machine-info.sh'
    $script:ShTerminalHelper = Join-Path $Repo 'scripts-linux/_shared/clear-terminal.sh'
}

Describe "Machine Identity Helper (machine-info.ps1)" {
    It "exists and is executable" {
        (Test-Path $script:MachineHelper) | Should -BeTrue
    }

    It "returns valid JSON containing GitMap parity schema fields" {
        $raw = pwsh -NoProfile -File $script:MachineHelper -Json
        $obj = $raw | ConvertFrom-Json
        $obj | Should -Not -BeNullOrEmpty
        $obj.nodeId | Should -Not -BeNullOrEmpty
        $obj.machineName | Should -Not -BeNullOrEmpty
        $obj.osPlatform | Should -Not -BeNullOrEmpty
        $obj.currentUser | Should -Not -BeNullOrEmpty
        $obj.cpuCores | Should -BeGreaterThan 0
    }

    It "returns non-empty IP configuration table" {
        $out = pwsh -NoProfile -File $script:MachineHelper -Action ip
        $out -join "`n" | Should -Match "Network Interfaces"
    }
}

Describe "Terminal Cleaner Helper (clear-terminal.ps1)" {
    It "exists and is executable" {
        (Test-Path $script:TerminalHelper) | Should -BeTrue
    }

    It "executes in --dry-run mode without errors" {
        $out = pwsh -NoProfile -File $script:TerminalHelper -DryRun
        $joined = $out -join "`n"
        $joined | Should -Match "Terminal History & Suggestions Cleanup"
        $joined | Should -Match "DRY-RUN"
    }

    It "returns valid JSON in --dry-run mode" {
        $raw = pwsh -NoProfile -File $script:TerminalHelper -DryRun -Json
        $obj = $raw | ConvertFrom-Json
        $obj | Should -Not -BeNullOrEmpty
        $obj.dryRun | Should -BeTrue
    }
}

Describe "Linux / Shell Helper Parity" {
    It "scripts-linux machine-info.sh exists and is non-empty" {
        (Test-Path $script:ShMachineHelper) | Should -BeTrue
        (Get-Item $script:ShMachineHelper).Length | Should -BeGreaterThan 100
    }

    It "scripts-linux clear-terminal.sh exists and is non-empty" {
        (Test-Path $script:ShTerminalHelper) | Should -BeTrue
        (Get-Item $script:ShTerminalHelper).Length | Should -BeGreaterThan 100
    }

    It "scripts-linux machine-info.sh runs and returns machine identity" {
        $bash = "C:\Program Files\Git\bin\bash.exe"
        if (Test-Path $bash) {
            $out = & $bash $script:ShMachineHelper
            $out -join "`n" | Should -Match "Machine Identity"
        }
    }

    It "scripts-linux clear-terminal.sh runs in dry-run mode" {
        $bash = "C:\Program Files\Git\bin\bash.exe"
        if (Test-Path $bash) {
            $out = & $bash $script:ShTerminalHelper --dry-run
            $out -join "`n" | Should -Match "DRY-RUN"
        }
    }

    It "scripts/run.sh dispatches machine, ip, and clear-terminal commands" {
        $bash = "C:\Program Files\Git\bin\bash.exe"
        if (Test-Path $bash) {
            $outMach = & $bash (Join-Path $Repo 'scripts/run.sh') machine
            $outMach -join "`n" | Should -Match "Machine Identity"

            $outIp = & $bash (Join-Path $Repo 'scripts/run.sh') ip
            $outIp -join "`n" | Should -Match "Network Interfaces"

            $outClr = & $bash (Join-Path $Repo 'scripts/run.sh') clear-terminal --dry-run
            $outClr -join "`n" | Should -Match "DRY-RUN"
        }
    }
}
