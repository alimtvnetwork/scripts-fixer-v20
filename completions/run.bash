# bash completion for run
_run_complete() {
  local cur prev
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"
  if [ "$COMP_CWORD" -eq 1 ]; then
    COMPREPLY=( $(compgen -W "install uninstall check repair list doctor version" -- "$cur") )
  else
    COMPREPLY=( $(compgen -W "01 02 03 04 05 06 07 08 09 10 100 101 102 103 104 105 106 107 108 109 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64 65 66 67 68 70 71 80 81 82 83 84 85 86 87 88 89 90 91 audit change-port-apache change-port-docker change-port-ftp change-port-menu change-port-mongodb change-port-mysql change-port-nginx change-port-postgresql change-port-rabbitmq change-port-redis change-port-smtp change-port-ssh conemu-context-menu context-menu-bundle databases install-all-dev-tools install-cassandra install-chrome install-conemu install-couchdb install-cpp install-dbeaver install-dns-bind9 install-dns-coredns install-dns-dnsmasq install-dns-knot install-dns-knot-resolver install-dns-menu install-dns-nsd install-dns-powerdns-auth install-dns-powerdns-recursor install-dns-unbound install-docker install-dotnet install-duckdb install-elasticsearch install-flameshot install-flutter install-git install-git-compact install-github-desktop install-gitmap install-golang install-java install-jenkins install-jumpjump-vpn install-kubernetes install-lightshot install-litedb install-llama-cpp install-mariadb install-mongodb install-mysql install-neo4j install-nodejs install-notepadpp install-obs install-ollama install-onenote install-package-managers install-php install-pnpm install-postgresql install-powershell install-protonvpn install-python install-python-libs install-redis install-rust install-sqlite install-sticky-notes install-ubuntu-font install-vlc install-vscode install-vscode-settings-sync install-whatsapp install-windows-terminal install-winget install-wordpress-ubuntu install-zsh install-zsh-clear install-zsh-theme-switcher os-clean pin-taskbar pwsh-context-menu remote-runner script-fixer-context-menu startup-add user-mgmt vscode-cleanup-linux vscode-context-menu-fix vscode-folder-repair vscode-folder-reregister vscode-menu-cleanup-mac vscode-menu-installer vscode-settings-sync windows-tweaks wt-context-menu all --json --help" -- "$cur") )
  fi
}
complete -F _run_complete run
complete -F _run_complete ./run.sh
