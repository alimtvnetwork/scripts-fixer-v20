import os

scripts_dir = "scripts/os/ubuntu"
run_sh = "scripts/run.sh"

files_content = {
    "update.sh": "#!/bin/bash\napt update -y && apt-get update -y && apt upgrade -y\n",
    "update-all.sh": "#!/bin/bash\napt update -y && apt-get update -y && apt upgrade -y && do-release-upgrade -y\n",
    
    # dependencies
    "dep-vim.sh": "#!/bin/bash\napt-get install -y vim\n",
    "dep-build-essential.sh": "#!/bin/bash\napt-get install -y build-essential\n",
    "dep-wget.sh": "#!/bin/bash\napt-get install -y wget\n",
    "dep-curl.sh": "#!/bin/bash\napt-get install -y curl\n",
    "dep-file.sh": "#!/bin/bash\napt-get install -y file\n",
    "dep-git.sh": "#!/bin/bash\napt-get install -y git\n",
    "dep-zlib1g.sh": "#!/bin/bash\napt-get install -y zlib1g\n",
    "dep-zlib1g-dev.sh": "#!/bin/bash\napt-get install -y zlib1g-dev\n",
    "dep-libssl-dev.sh": "#!/bin/bash\napt-get install -y libssl-dev\n",
    "dep-aria2c.sh": "#!/bin/bash\napt-get install -y aria2\n",
    
    # core tools
    "install-docker.sh": "#!/bin/bash\napt-get install -y docker.io docker-compose\nsystemctl enable --now docker\n",
    "install-kubernetes.sh": "#!/bin/bash\ncurl -LO \"https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl\"\nchmod +x kubectl && mv kubectl /usr/local/bin/\n",
    "install-python2.sh": "#!/bin/bash\napt-get install -y python2\n",
    "install-python3.sh": "#!/bin/bash\napt-get install -y python3 python3-pip python3-venv\n",
    "install-php.sh": "#!/bin/bash\napt-get install -y php php-cli php-fpm\n",
    "install-rust.sh": "#!/bin/bash\ncurl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y\n",
    "install-golang.sh": "#!/bin/bash\napt-get install -y golang\n",
    "install-node.sh": "#!/bin/bash\ncurl -fsSL https://deb.nodesource.com/setup_lts.x | bash -\napt-get install -y nodejs\n",
    "install-pnpm.sh": "#!/bin/bash\nnpm install -g pnpm\n",
    "install-yarn.sh": "#!/bin/bash\nnpm install -g yarn\n",
    "install-git-lfs.sh": "#!/bin/bash\napt-get install -y git-lfs\ngit lfs install\n",
    "install-gh.sh": "#!/bin/bash\napt-get install -y gh\n",
    "install-dbeaver.sh": "#!/bin/bash\nsnap install dbeaver-ce\n",
    "install-github-desktop.sh": "#!/bin/bash\nsnap install github-desktop --beta\n",
    "install-sticky-notes.sh": "#!/bin/bash\nsnap install rhinote\n",
    
    # zsh
    "dep-omyzsh.sh": "#!/bin/bash\napt-get install -y zsh\nsh -c \"$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)\" \"\" --unattended\n",
    "dep-zsh-autosuggestions.sh": "#!/bin/bash\ngit clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions\n",
    
    # profiles
    "profile-ubuntu-basic.sh": "#!/bin/bash\nbash scripts/os/ubuntu/dep-git.sh\nbash scripts/os/ubuntu/dep-omyzsh.sh\nbash scripts/os/ubuntu/dep-zsh-autosuggestions.sh\nbash scripts/os/ubuntu/dep-aria2c.sh\napt-get install -y vim build-essential wget curl file zlib1g zlib1g-dev libssl-dev\n",
    "profile-ubuntu-vscode.sh": "#!/bin/bash\nbash scripts/os/ubuntu/profile-ubuntu-basic.sh\nsnap install code --classic\n",
    "profile-ubuntu-simple-dev.sh": "#!/bin/bash\nbash scripts/os/ubuntu/profile-ubuntu-vscode.sh\nbash scripts/os/ubuntu/install-golang.sh\nbash scripts/os/ubuntu/install-rust.sh\nbash scripts/os/ubuntu/install-php.sh\nbash scripts/os/ubuntu/install-python3.sh\n",
    "profile-ubuntu-dev.sh": "#!/bin/bash\nbash scripts/os/ubuntu/profile-ubuntu-simple-dev.sh\nbash scripts/os/ubuntu/install-node.sh\nbash scripts/os/ubuntu/install-pnpm.sh\n"
}

os.makedirs(scripts_dir, exist_ok=True)
for fname, content in files_content.items():
    path = os.path.join(scripts_dir, fname)
    with open(path, "w", encoding="utf-8") as f:
        f.write(content)

# Populate run.sh
run_sh_content = """#!/bin/bash
COMMAND=$1
ARGS=$2

case "$COMMAND" in
    "os")
        if [ "$ARGS" = "update-all" ]; then
            bash scripts/os/ubuntu/update-all.sh
        elif [ "$ARGS" = "update" ]; then
            bash scripts/os/ubuntu/update.sh
        fi
        ;;
    "install")
        if [[ "$ARGS" == *"zsh,zsh+config"* ]]; then
            bash scripts/os/ubuntu/dep-omyzsh.sh
            bash scripts/os/ubuntu/dep-zsh-autosuggestions.sh
        elif [[ "$ARGS" == *"profile ubuntu+dev"* ]]; then
            bash scripts/os/ubuntu/profile-ubuntu-dev.sh
        elif [[ "$ARGS" == *"profile ubuntu+simple-dev"* ]]; then
            bash scripts/os/ubuntu/profile-ubuntu-simple-dev.sh
        elif [[ "$ARGS" == *"profile ubuntu+vscode"* ]]; then
            bash scripts/os/ubuntu/profile-ubuntu-vscode.sh
        elif [[ "$ARGS" == *"profile ubuntu-basic"* ]]; then
            bash scripts/os/ubuntu/profile-ubuntu-basic.sh
        else
            echo "Unknown install argument: $ARGS"
        fi
        ;;
    *)
        echo "Usage: ./run os [update|update-all]"
        echo "       ./run install [zsh,zsh+config | profile ubuntu+dev]"
        ;;
esac
"""
with open(run_sh, "w", encoding="utf-8") as f:
    f.write(run_sh_content)
    
print("Successfully populated all bash scripts with actual implementation logic.")
