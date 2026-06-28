# Pester smoke tests for cross-platform helpers.
# Run with: Invoke-Pester -Path tests/pester

BeforeAll {
    $script:Repo = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
}

Describe "Repo invariants" {
    It "version.json has a semver string" {
        $v = (Get-Content (Join-Path $Repo 'version.json') -Raw | ConvertFrom-Json).version
        $v | Should -Match '^\d+\.\d+\.\d+$'
    }

    It "registry.yaml exists and is non-empty" {
        $p = Join-Path $Repo 'registry.yaml'
        (Test-Path $p) | Should -BeTrue
        (Get-Item $p).Length | Should -BeGreaterThan 100
    }

    It "every Windows manifest declares an id" {
        Get-ChildItem (Join-Path $Repo 'scripts') -Recurse -Filter manifest.json | ForEach-Object {
            $m = Get-Content $_.FullName -Raw | ConvertFrom-Json
            $m.id | Should -Not -BeNullOrEmpty -Because "$($_.FullName) missing id"
        }
    }
}

Describe "Core helpers" {
    It "core/state.ps1 loads without error" {
        { . (Join-Path $Repo 'core/state.ps1') } | Should -Not -Throw
    }
    It "core/json-output.ps1 loads without error" {
        { . (Join-Path $Repo 'core/json-output.ps1') } | Should -Not -Throw
    }
}
