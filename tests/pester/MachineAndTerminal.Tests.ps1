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
}
