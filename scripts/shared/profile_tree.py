import sys
if hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except:
        pass

import os
import json

# Built-in Ubuntu Profile definitions
PROFILES = {
    "ubuntu-basic": {
        "title": "Ubuntu Basic Foundation",
        "description": "Essential CLI toolchain, version control, modern shell environment, and compilation dependencies.",
        "tree": [
            "ubuntu-basic",
            "├── git (Distributed version control system & GitHub tools)",
            "├── zsh + oh-my-zsh (Z-Shell with syntax highlighting & autosuggestions)",
            "├── aria2c (High-speed multi-source download utility)",
            "└── build-essential & core utils (gcc, g++, make, vim, curl, wget, libssl-dev, zlib1g)"
        ],
        "steps": [
            ("1. Git & CLI Tools", "Installs latest git PPA, curl, wget, vim, aria2, and essential archiving tools."),
            ("2. ZSH & Oh-My-Zsh", "Installs Zsh shell, configures Oh-My-Zsh framework, and clones zsh-autosuggestions plugin."),
            ("3. C/C++ Build Environment", "Installs build-essential (gcc, g++, make), libssl-dev, and zlib1g-dev for native compiling.")
        ]
    },
    "ubuntu+vscode": {
        "title": "Ubuntu + VS Code",
        "description": "Ubuntu Basic Foundation combined with Visual Studio Code IDE environment.",
        "tree": [
            "ubuntu+vscode",
            "├── ubuntu-basic (Inherited base toolchain & shell)",
            "│   ├── git (Version control)",
            "│   ├── zsh + oh-my-zsh (Shell environment)",
            "│   ├── aria2c (Download accelerator)",
            "│   └── build-essential & core tools",
            "└── vscode (Visual Studio Code IDE via canonical snap classic)"
        ],
        "steps": [
            ("1. Base Foundation", "Executes full ubuntu-basic setup (git, zsh, build-essential, vim, curl, aria2c)."),
            ("2. VS Code IDE", "Installs Visual Studio Code snap with --classic confinement for full filesystem access.")
        ]
    },
    "ubuntu+simple-dev": {
        "title": "Ubuntu Simple Dev (ubuntu+small-dev)",
        "description": "Complete multi-language developer workstation with VS Code, Go, Rust, PHP, and Python 3.",
        "tree": [
            "ubuntu+small-dev (ubuntu+simple-dev)",
            "├── ubuntu+vscode (Base environment + VS Code IDE)",
            "│   ├── ubuntu-basic (git, zsh, build-essential, aria2c, vim, curl)",
            "│   └── vscode (Visual Studio Code)",
            "├── golang (Go compiler, GOPATH & Go runtime tooling)",
            "├── rust (Rust toolchain, rustup installer & cargo package manager)",
            "├── php (PHP 8.x CLI, PHP-FPM, core extensions & composer readiness)",
            "└── python3 (Python 3.x, pip, python3-venv isolated virtualenvs & dev headers)"
        ],
        "steps": [
            ("1. Base & Editor", "Deploys ubuntu+vscode (git, zsh, build-essential, aria2c, and VS Code IDE)."),
            ("2. Golang Runtime", "Installs Go compiler, sets up workspace directories, and verifies go version."),
            ("3. Rust & Cargo", "Installs rustup toolchain, stable compiler, and cargo package manager."),
            ("4. PHP 8.x Environment", "Installs php, php-cli, php-fpm, readline, and core modules with systemd service."),
            ("5. Python 3 Toolchain", "Installs python3, pip, python3-venv, and dev headers for package compilation.")
        ]
    },
    "ubuntu+small-dev": {
        "alias_of": "ubuntu+simple-dev"
    },
    "ubuntu+dev": {
        "title": "Ubuntu Full Dev Workstation",
        "description": "Full-stack development environment containing all simple-dev runtimes plus Node.js, PNPM, and Yarn.",
        "tree": [
            "ubuntu+dev",
            "├── ubuntu+simple-dev (Base + VS Code + Go + Rust + PHP + Python3)",
            "│   ├── ubuntu+vscode (git, zsh, build-essential, aria2c, vscode)",
            "│   ├── golang (Go compiler & tools)",
            "│   ├── rust (Rust toolchain & cargo)",
            "│   ├── php (PHP 8.x CLI & FPM)",
            "│   └── python3 (Python 3.x, pip, venv)",
            "├── nodejs (Node.js LTS runtime & global npm)",
            "├── pnpm (Fast, disk space efficient package manager)",
            "└── yarn (Classic / Modern Yarn package manager)"
        ],
        "steps": [
            ("1. Simple Dev Stack", "Deploys all ubuntu+simple-dev components (Base, VS Code, Go, Rust, PHP, Python)."),
            ("2. Node.js LTS", "Installs NodeSource LTS repository and configures node & npm binary paths."),
            ("3. Modern Package Managers", "Installs pnpm and yarn globally for high-performance dependency resolution.")
        ]
    }
}

def load_windows_profiles():
    # Attempt to load scripts/profile/config.json
    base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    win_cfg_path = os.path.join(base_dir, "profile", "config.json")
    if not os.path.exists(win_cfg_path):
        return
    try:
        with open(win_cfg_path, "r", encoding="utf-8") as f:
            cfg = json.load(f)
        if "profiles" in cfg:
            for name, pdata in cfg["profiles"].items():
                if name in PROFILES:
                    continue
                label = pdata.get("label", name)
                desc = pdata.get("description", label)
                steps_data = pdata.get("steps", [])
                
                tree_lines = [name]
                step_tuples = []
                for i, s in enumerate(steps_data):
                    s_kind = s.get("kind", "")
                    s_label = s.get("label", s.get("name", s.get("package", s.get("function", s_kind))))
                    is_last = (i == len(steps_data) - 1)
                    prefix = "└── " if is_last else "├── "
                    tree_lines.append(f"{prefix}{s_label} ({s_kind})")
                    step_tuples.append((f"{i+1}. {s_label}", f"Configures {s_label} via {s_kind} pipeline."))
                
                PROFILES[name] = {
                    "title": label,
                    "description": desc,
                    "tree": tree_lines,
                    "steps": step_tuples
                }
    except Exception:
        pass

load_windows_profiles()

def resolve_profile(name):
    clean_name = name.strip().lower()
    if clean_name.startswith("profile-"):
        clean_name = clean_name[8:]
    if clean_name.endswith("-profile"):
        clean_name = clean_name[:-8]
    if clean_name.startswith("profile "):
        clean_name = clean_name[8:].strip()

    if clean_name in PROFILES:
        prof = PROFILES[clean_name]
        if "alias_of" in prof:
            return PROFILES[prof["alias_of"]], prof["alias_of"]
        return prof, clean_name
    return None, clean_name

def print_tree(name, use_colors=True):
    prof, actual_name = resolve_profile(name)
    if not prof:
        print(f"Unknown profile: {name}")
        return
    
    c_green = "\033[1;32m" if use_colors else ""
    c_cyan = "\033[1;36m" if use_colors else ""
    c_yellow = "\033[1;33m" if use_colors else ""
    c_gray = "\033[0;37m" if use_colors else ""
    c_reset = "\033[0m" if use_colors else ""

    print(f"\n  {c_green}Profile Structure:{c_reset} {c_cyan}{actual_name}{c_reset} - {c_yellow}{prof['title']}{c_reset}")
    print(f"  {c_gray}{prof['description']}{c_reset}\n")
    print(f"  {c_green}Hierarchy Tree:{c_reset}")
    for line in prof["tree"]:
        print(f"    {c_cyan}{line}{c_reset}")
    print(f"\n  {c_green}Step-by-Step Components Breakdown:{c_reset}")
    for step_title, step_desc in prof["steps"]:
        print(f"    {c_yellow}✔ {step_title}{c_reset}")
        print(f"      {c_gray}{step_desc}{c_reset}")
    print("")

def print_all_profiles(use_colors=True):
    c_green = "\033[1;32m" if use_colors else ""
    c_cyan = "\033[1;36m" if use_colors else ""
    c_yellow = "\033[1;33m" if use_colors else ""
    c_gray = "\033[0;37m" if use_colors else ""
    c_reset = "\033[0m" if use_colors else ""

    print(f"\n  {c_green}======================================================={c_reset}")
    print(f"  {c_green}            AVAILABLE SYSTEM PROFILES                  {c_reset}")
    print(f"  {c_green}======================================================={c_reset}\n")

    for key in sorted(PROFILES.keys()):
        prof = PROFILES[key]
        if "alias_of" in prof:
            continue
        print(f"  {c_cyan}► {key}{c_reset} - {c_yellow}{prof['title']}{c_reset}")
        print(f"    {c_gray}{prof['description']}{c_reset}")
        print(f"    {c_green}Installation Tree:{c_reset}")
        for line in prof["tree"]:
            print(f"      {c_gray}{line}{c_reset}")
        print(f"    {c_green}Included Steps:{c_reset}")
        for step_title, step_desc in prof["steps"][:3]:
            print(f"      {c_yellow}• {step_title}:{c_reset} {c_gray}{step_desc}{c_reset}")
        if len(prof["steps"]) > 3:
            print(f"      {c_gray}... (+{len(prof['steps']) - 3} more steps){c_reset}")
        print(f"    {c_green}Command:{c_reset} {c_cyan}install {key}{c_reset}\n")

if __name__ == "__main__":
    if len(sys.argv) > 1:
        cmd = sys.argv[1].lower()
        if cmd in ["all", "list", "help"]:
            print_all_profiles()
        elif cmd in ["describe", "tree", "summary"] and len(sys.argv) > 2:
            print_tree(sys.argv[2])
        else:
            print_tree(cmd)
    else:
        print_all_profiles()
