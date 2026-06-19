# scripts/58-install-chrome/tests/profile-copy.test.ps1
# -----------------------------------------------------------------------------
# Windows smoke tests for the chrome-profile-copy helper.
#
# Mirrors scripts-linux/_shared/tests/chrome-profile-copy.test.sh: all I/O is
# sandboxed under a temp $env:LOCALAPPDATA so the test never touches a real
# Chrome install.
#
# Run:
#   Install-Module Pester -Scope CurrentUser -Force   # one-time
#   Invoke-Pester scripts\58-install-chrome\tests\profile-copy.test.ps1
# -----------------------------------------------------------------------------
#Requires -Version 5.1

BeforeAll {
    $script:TestDir   = Split-Path -Parent $PSCommandPath
    $script:ScriptDir = Split-Path -Parent $script:TestDir
    $script:RepoRoot  = Split-Path -Parent (Split-Path -Parent $script:ScriptDir)
    $script:SharedDir = Join-Path $script:RepoRoot 'scripts\shared'

    . (Join-Path $script:SharedDir 'logging.ps1')
    . (Join-Path $script:ScriptDir 'helpers\profile-copy.ps1')

    Initialize-Logging -ScriptName 'profile-copy-test'

    function New-FakeChromeProfile {
        param([string]$UserData, [string]$Name)
        $profile = Join-Path $UserData $Name
        New-Item -ItemType Directory -Path $profile -Force | Out-Null

        # Bookmarks
        $bookmarks = @{
            roots = @{
                bookmark_bar = @{
                    name = 'Bookmarks bar'
                    type = 'folder'
                    children = @(
                        @{ type='url'; name='Lovable'; url='https://lovable.dev' },
                        @{ type='url'; name='GitHub';  url='https://github.com' }
                    )
                }
                other = @{ name='Other'; type='folder'; children=@() }
            }
        }
        ($bookmarks | ConvertTo-Json -Depth 12) |
            Set-Content -LiteralPath (Join-Path $profile 'Bookmarks') -Encoding UTF8

        # Preferences w/ account_info that MUST be stripped on copy/import
        $prefs = @{
            homepage = 'https://lovable.dev'
            homepage_is_newtabpage = $false
            account_info = @(@{ email='user@example.com'; gaia='1234567890' })
            google       = @{ services = @{ username='user@example.com' } }
            signin       = @{ allowed = $true }
        }
        ($prefs | ConvertTo-Json -Depth 12 -Compress) |
            Set-Content -LiteralPath (Join-Path $profile 'Preferences') -Encoding UTF8

        # Fake extension
        $extVer = Join-Path $profile 'Extensions\aaaabbbbccccddddeeeeffff00001111\1.0.0_0'
        New-Item -ItemType Directory -Path $extVer -Force | Out-Null
        '{ "name":"Fake Ext", "version":"1.0.0", "manifest_version":3 }' |
            Set-Content -LiteralPath (Join-Path $extVer 'manifest.json') -Encoding UTF8

        # Cache must NEVER be copied
        $cacheDir = Join-Path $profile 'Cache'
        New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null
        'garbage' | Set-Content -LiteralPath (Join-Path $cacheDir 'data') -Encoding UTF8
    }

    function New-FakeChromeRoot {
        $sandbox = Join-Path ([IO.Path]::GetTempPath()) ("cpc-" + [guid]::NewGuid().ToString('N').Substring(0,8))
        New-Item -ItemType Directory -Path $sandbox -Force | Out-Null
        $userData = Join-Path $sandbox 'Google\Chrome\User Data'
        New-Item -ItemType Directory -Path $userData -Force | Out-Null
        $localState = @{ profile = @{ info_cache = @{ Default = @{ name = 'Default' } } } }
        ($localState | ConvertTo-Json -Depth 8) |
            Set-Content -LiteralPath (Join-Path $userData 'Local State') -Encoding UTF8
        New-FakeChromeProfile -UserData $userData -Name 'Default'
        return $sandbox
    }
}

Describe 'Copy-ChromeProfile (sandboxed)' {
    BeforeEach {
        $script:Sandbox      = New-FakeChromeRoot
        $script:OldLocalApp  = $env:LOCALAPPDATA
        $env:LOCALAPPDATA    = $script:Sandbox
        Mock Test-ChromeRunning { return $false }
    }
    AfterEach {
        $env:LOCALAPPDATA = $script:OldLocalApp
        if ($script:Sandbox -and (Test-Path $script:Sandbox)) {
            Remove-Item $script:Sandbox -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    It 'creates the target profile, copies Bookmarks + Extensions, and skips Cache' {
        $ok = Copy-ChromeProfile -From 'Default' -To 'Profile 99' -Force
        $ok | Should -BeTrue

        $dst = Join-Path $env:LOCALAPPDATA 'Google\Chrome\User Data\Profile 99'
        Test-Path (Join-Path $dst 'Bookmarks')                                                | Should -BeTrue
        Test-Path (Join-Path $dst 'Extensions\aaaabbbbccccddddeeeeffff00001111\1.0.0_0\manifest.json') | Should -BeTrue
        Test-Path (Join-Path $dst 'Cache')                                                    | Should -BeFalse
    }

    It 'strips account_info / google / signin from copied Preferences' {
        Copy-ChromeProfile -From 'Default' -To 'Offline' -Force | Out-Null
        $prefs = Get-Content -Raw -LiteralPath (Join-Path $env:LOCALAPPDATA 'Google\Chrome\User Data\Offline\Preferences') |
                 ConvertFrom-Json
        $prefs.PSObject.Properties.Name | Should -Not -Contain 'account_info'
        $prefs.PSObject.Properties.Name | Should -Not -Contain 'google'
        $prefs.PSObject.Properties.Name | Should -Not -Contain 'signin'
        $prefs.homepage | Should -Be 'https://lovable.dev'
    }

    It 'registers the new profile in Local State' {
        Copy-ChromeProfile -From 'Default' -To 'Side' -Force | Out-Null
        $ls = Get-Content -Raw -LiteralPath (Join-Path $env:LOCALAPPDATA 'Google\Chrome\User Data\Local State') |
              ConvertFrom-Json
        $ls.profile.info_cache.PSObject.Properties.Name | Should -Contain 'Side'
    }

    It '-DryRun does not create the target directory' {
        Copy-ChromeProfile -From 'Default' -To 'Ghost' -DryRun -Force | Out-Null
        Test-Path (Join-Path $env:LOCALAPPDATA 'Google\Chrome\User Data\Ghost') | Should -BeFalse
    }

    It 'fails with a path-bearing error when the source profile is missing' {
        $ok = Copy-ChromeProfile -From 'NoSuchProfile' -To 'X' -Force
        $ok | Should -BeFalse
    }
}

Describe 'Export-ChromeProfile + Import-ChromeProfile round-trip' {
    BeforeEach {
        $script:Sandbox     = New-FakeChromeRoot
        $script:OldLocalApp = $env:LOCALAPPDATA
        $env:LOCALAPPDATA   = $script:Sandbox
        Mock Test-ChromeRunning { return $false }
    }
    AfterEach {
        $env:LOCALAPPDATA = $script:OldLocalApp
        if ($script:Sandbox -and (Test-Path $script:Sandbox)) {
            Remove-Item $script:Sandbox -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    It 'writes profile.json + profile.csv with bookmark and extension rows' {
        $outDir = Join-Path $script:Sandbox 'export'
        Export-ChromeProfile -Name 'Default' -OutDir $outDir -Format both | Should -BeTrue

        Test-Path (Join-Path $outDir 'profile.json') | Should -BeTrue
        Test-Path (Join-Path $outDir 'profile.csv')  | Should -BeTrue

        $snap = Get-Content -Raw -LiteralPath (Join-Path $outDir 'profile.json') | ConvertFrom-Json
        $snap.'$schema' | Should -Be 'chrome-profile-export/v1'
        @($snap.extensions).Count | Should -BeGreaterThan 0

        $csv = Get-Content -Raw -LiteralPath (Join-Path $outDir 'profile.csv')
        $csv | Should -Match 'bookmark'
        $csv | Should -Match 'extension'
    }

    It 'Import-ChromeProfile creates the target with Bookmarks + Preferences from snapshot' {
        $outDir = Join-Path $script:Sandbox 'export'
        Export-ChromeProfile -Name 'Default' -OutDir $outDir -Format json | Out-Null

        $ok = Import-ChromeProfile -JsonPath (Join-Path $outDir 'profile.json') -To 'Imported' -Force
        $ok | Should -BeTrue

        $dst = Join-Path $env:LOCALAPPDATA 'Google\Chrome\User Data\Imported'
        Test-Path (Join-Path $dst 'Bookmarks')   | Should -BeTrue
        Test-Path (Join-Path $dst 'Preferences') | Should -BeTrue

        $ls = Get-Content -Raw -LiteralPath (Join-Path $env:LOCALAPPDATA 'Google\Chrome\User Data\Local State') |
              ConvertFrom-Json
        $ls.profile.info_cache.PSObject.Properties.Name | Should -Contain 'Imported'
    }
}
