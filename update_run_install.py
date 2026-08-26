with open("scripts/run.sh", "r", encoding="utf-8") as f:
    run_sh = f.read()

# We need to rewrite the `case "$COMMAND" in "install")` block.
import re

install_block_regex = re.compile(r'    "install"\)\n(.*?)        ;;\n    \*\)', re.DOTALL)
match = install_block_regex.search(run_sh)

if match:
    old_install = match.group(1)
    
    new_install = """        # Sub-help handling
        if [[ "$ARGS" == *"profile help"* || "$ARGS" == *"profile -h"* || "$ARGS" == *"profile --help"* || "$ARGS" == *"profile -help"* ]]; then
            show_profile_help
            show_footer
            exit 0
        elif [[ "$ARGS" == *"help"* || "$ARGS" == *"-h"* || "$ARGS" == *"--help"* || "$ARGS" == *"-help"* ]]; then
            show_install_help
            show_footer
            exit 0
        fi

        INSTALLED=()

        # Split by comma
        IFS=',' read -ra ITEMS <<< "$ARGS"
        for ITEM in "${ITEMS[@]}"; do
            # Trim spaces
            ITEM=$(echo "$ITEM" | xargs)
            
            if [ -z "$ITEM" ]; then continue; fi
            
            SUCCESS=false
            echo -e "  ${SECONDARY}Processing: $ITEM${TEXT}"

            # Profile installation
            if [[ "$ITEM" == *"profile ubuntu+dev"* ]]; then
                bash scripts/os/ubuntu/profile-ubuntu-dev.sh && SUCCESS=true
            elif [[ "$ITEM" == *"profile ubuntu+small-dev"* || "$ITEM" == *"profile ubuntu+simple-dev"* ]]; then
                bash scripts/os/ubuntu/profile-ubuntu-simple-dev.sh && SUCCESS=true
            elif [[ "$ITEM" == *"profile ubuntu+vscode"* ]]; then
                bash scripts/os/ubuntu/profile-ubuntu-vscode.sh && SUCCESS=true
            elif [[ "$ITEM" == *"profile ubuntu-basic"* ]]; then
                bash scripts/os/ubuntu/profile-ubuntu-basic.sh && SUCCESS=true
            
            # Tools
            elif [[ "$ITEM" == *"docker"* || "$ITEM" == *"47"* ]]; then bash scripts/os/ubuntu/install-docker.sh && SUCCESS=true
            elif [[ "$ITEM" == *"kubernetes"* || "$ITEM" == *"46"* ]]; then bash scripts/os/ubuntu/install-kubernetes.sh && SUCCESS=true
            elif [[ "$ITEM" == *"python2"* ]]; then bash scripts/os/ubuntu/install-python2.sh && SUCCESS=true
            elif [[ "$ITEM" == *"python3"* || "$ITEM" == *"python"* || "$ITEM" == *"05"* ]]; then bash scripts/os/ubuntu/install-python3.sh && SUCCESS=true
            elif [[ "$ITEM" == *"rust"* || "$ITEM" == *"20"* ]]; then bash scripts/os/ubuntu/install-rust.sh && SUCCESS=true
            elif [[ "$ITEM" == *"golang"* || "$ITEM" == *"06"* ]]; then bash scripts/os/ubuntu/install-golang.sh && SUCCESS=true
            elif [[ "$ITEM" == *"node"* || "$ITEM" == *"nodejs"* || "$ITEM" == *"03"* ]]; then bash scripts/os/ubuntu/install-node.sh && SUCCESS=true
            elif [[ "$ITEM" == *"pnpm"* || "$ITEM" == *"04"* ]]; then bash scripts/os/ubuntu/install-pnpm.sh && SUCCESS=true
            elif [[ "$ITEM" == *"yarn"* ]]; then bash scripts/os/ubuntu/install-yarn.sh && SUCCESS=true
            elif [[ "$ITEM" == *"php"* || "$ITEM" == *"16"* ]]; then bash scripts/os/ubuntu/install-php.sh && SUCCESS=true
            elif [[ "$ITEM" == *"git-lfs"* || "$ITEM" == *"gh"* || "$ITEM" == *"git"* || "$ITEM" == *"07"* ]]; then 
                bash scripts/os/ubuntu/install-git-lfs.sh && bash scripts/os/ubuntu/install-gh.sh && SUCCESS=true
            elif [[ "$ITEM" == *"dbeaver"* || "$ITEM" == *"32"* ]]; then bash scripts/os/ubuntu/install-dbeaver.sh && SUCCESS=true
            elif [[ "$ITEM" == *"github-desktop"* || "$ITEM" == *"33"* ]]; then bash scripts/os/ubuntu/install-github-desktop.sh && SUCCESS=true
            elif [[ "$ITEM" == *"sticky-notes"* || "$ITEM" == *"34"* ]]; then bash scripts/os/ubuntu/install-sticky-notes.sh && SUCCESS=true
            elif [[ "$ITEM" == *"vscode"* || "$ITEM" == *"01"* ]]; then bash scripts/os/ubuntu/profile-ubuntu-vscode.sh && SUCCESS=true
            elif [[ "$ITEM" == *"zsh,zsh+config"* || "$ITEM" == *"zsh+config"* || "$ITEM" == *"51"* ]]; then
                bash scripts/os/ubuntu/dep-omyzsh.sh
                bash scripts/os/ubuntu/dep-zsh-autosuggestions.sh
                SUCCESS=true
            elif [[ "$ITEM" == *"zsh"* || "$ITEM" == *"50"* ]]; then
                bash scripts/os/ubuntu/dep-omyzsh.sh && SUCCESS=true
            elif [[ "$ITEM" == *"build-essential"* || "$ITEM" == *"21"* ]]; then
                bash scripts/os/ubuntu/dep-build-essential.sh && SUCCESS=true
            elif [[ "$ITEM" == *"curl"* || "$ITEM" == *"22"* ]]; then
                bash scripts/os/ubuntu/dep-curl.sh && SUCCESS=true
            elif [[ "$ITEM" == *"wget"* || "$ITEM" == *"23"* ]]; then
                bash scripts/os/ubuntu/dep-wget.sh && SUCCESS=true
            elif [[ "$ITEM" == *"vim"* || "$ITEM" == *"24"* ]]; then
                bash scripts/os/ubuntu/dep-vim.sh && SUCCESS=true
            elif [[ "$ITEM" == *"ssh"* || "$ITEM" == *"25"* ]]; then
                PORT=$(echo "$ITEM" | grep -oE '[0-9]+' | head -n 1)
                bash scripts/os/ubuntu/install-ssh.sh "$PORT" && SUCCESS=true
            elif [[ "$ITEM" == *"aria2c"* || "$ITEM" == *"26"* ]]; then
                bash scripts/os/ubuntu/dep-aria2c.sh && SUCCESS=true
            else
                echo -e "  ${ERROR}Unknown install argument: $ITEM${TEXT}"
                echo -e "  Run './run.sh install help' for more details."
            fi

            if [ "$SUCCESS" = true ]; then
                INSTALLED+=("$ITEM")
                python3 scripts/shared/logger.py "$ITEM"
            fi
        done

        if [ ${#INSTALLED[@]} -gt 0 ]; then
            echo -e "\n  ${PRIMARY}Installation Summary:${TEXT}"
            for p in "${INSTALLED[@]}"; do
                echo -e "    ${SECONDARY}✔${TEXT} $p"
            done
        fi
"""
    run_sh = run_sh[:match.start(1)] + new_install + run_sh[match.end(1):]
    with open("scripts/run.sh", "w", encoding="utf-8", newline='\n') as f:
        f.write(run_sh)
    print("Updated run.sh with comma-separated arguments, logging, and summary.")
else:
    print("Could not find install block in run.sh")
