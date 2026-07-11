# Pester smoke tests for scripts-linux/60-install-zsh config + payload.
# Complements the BATS suite (which exercises bash-specific paths).

Describe '60-install-zsh config + payload' {
    BeforeAll {
        $Root       = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
        $script:Dir = Join-Path $Root 'scripts-linux/60-install-zsh'
        $script:Cfg = Get-Content (Join-Path $script:Dir 'config.json') -Raw | ConvertFrom-Json
        $script:Extras = Get-Content (Join-Path $script:Dir 'payload/zshrc-extras') -Raw
    }

    It 'declares powerlevel10k / starship / spaceship theme_presets' {
        $keys = $script:Cfg.theme_presets.PSObject.Properties.Name
        $keys | Should -Contain 'powerlevel10k'
        $keys | Should -Contain 'starship'
        $keys | Should -Contain 'spaceship'
    }

    It 'lists history-substring-search in default plugins' {
        $script:Cfg.plugins | Should -Contain 'history-substring-search'
    }

    It 'clones zsh-history-substring-search as a custom plugin' {
        ($script:Cfg.custom_plugins | Where-Object { $_.name -eq 'zsh-history-substring-search' }).Count | Should -Be 1
    }

    It 'wires autosuggest-accept + history-substring-search bindings in extras payload' {
        $script:Extras | Should -Match 'autosuggest-accept'
        $script:Extras | Should -Match 'history-substring-search-up'
        $script:Extras | Should -Match 'history-substring-search-down'
    }

    It 'zsh-fanout playbook exists and is wired into docs/parity-matrix.md' {
        $repo = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
        Test-Path (Join-Path $repo 'scripts-orchestrator/playbooks/zsh-fanout/playbook.json') | Should -BeTrue
        (Get-Content (Join-Path $repo 'docs/parity-matrix.md') -Raw) | Should -Match 'zsh-fanout'
    }
}
