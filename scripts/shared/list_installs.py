import sys
if hasattr(sys.stdout, "reconfigure"):
    try:
        sys.stdout.reconfigure(encoding="utf-8")
    except:
        pass

import sqlite3
import os

TOOL_DESCRIPTIONS = {
    "11": "VS Code Settings, Keybindings & Curated Extensions Sync",
    "vscode-settings": "VS Code Settings, Keybindings & Curated Extensions Sync",
    "vscode+settings": "VS Code IDE + Settings & Extensions Sync",
    "bcompare": "Beyond Compare Diff & Merge Tool (Git Diff/Merge integrated)",
    "beyondcompare": "Beyond Compare Diff & Merge Tool (Git Diff/Merge integrated)",
    "bc": "Beyond Compare Diff & Merge Tool (Git Diff/Merge integrated)",
    "ollama": "Ollama Local LLM Runner & Models (Qwen, DeepSeek, GLM, Kimi)",
    "llm": "Local LLM Execution Stack (Ollama + Models)",
    "models": "Local LLM Model Catalog & Execution Suite",
    "clean": "System Deep Cleanup (APT cache, logs & temporary files)",
    "cleanup": "System Deep Cleanup (APT cache, logs & temporary files)",
    "fastfetch": "Fastfetch System Information & Hardware Diagnostic Utility",
    "tools": "Modern CLI Dev Tools (fastfetch, bat, eza, ripgrep, fzf)",
    "cli-tools": "Modern CLI Dev Tools (fastfetch, bat, eza, ripgrep, fzf)",
    "01": "Visual Studio Code IDE (snap classic)",
    "vscode": "Visual Studio Code IDE (snap classic)",
    "03": "Node.js LTS Runtime & Yarn Package Manager",
    "nodejs": "Node.js LTS Runtime & Yarn Package Manager",
    "node": "Node.js LTS Runtime & Yarn Package Manager",
    "04": "pnpm Fast Disk-Efficient Package Manager",
    "pnpm": "pnpm Fast Disk-Efficient Package Manager",
    "05": "Python 3 Runtime, Pip & Virtualenv Toolchain",
    "python3": "Python 3 Runtime, Pip & Virtualenv Toolchain",
    "python": "Python 3 Runtime, Pip & Virtualenv Toolchain",
    "06": "Go Compiler, Runtime & Workspace Setup",
    "golang": "Go Compiler, Runtime & Workspace Setup",
    "go": "Go Compiler, Runtime & Workspace Setup",
    "07": "Git Version Control, Git LFS & GitHub CLI",
    "git": "Git Version Control, Git LFS & GitHub CLI",
    "16": "PHP 8.x CLI, FPM & Core Modules",
    "php": "PHP 8.x CLI, FPM & Core Modules",
    "20": "Rust Toolchain, Rustup & Cargo Package Manager",
    "rust": "Rust Toolchain, Rustup & Cargo Package Manager",
    "21": "Build Essential C/C++ Compiler Suite (gcc, g++, make)",
    "build-essential": "Build Essential C/C++ Compiler Suite (gcc, g++, make)",
    "22": "cURL Network Data Transfer Tool",
    "curl": "cURL Network Data Transfer Tool",
    "23": "Wget File Downloader Utility",
    "wget": "Wget File Downloader Utility",
    "24": "Vim Advanced Terminal Text Editor",
    "vim": "Vim Advanced Terminal Text Editor",
    "25": "OpenSSH Server & Configured Port Access",
    "ssh": "OpenSSH Server & Configured Port Access",
    "26": "Aria2 High-Speed Multi-Source Download Utility",
    "aria2c": "Aria2 High-Speed Multi-Source Download Utility",
    "32": "DBeaver Universal Database GUI Tool",
    "dbeaver": "DBeaver Universal Database GUI Tool",
    "33": "GitHub Desktop GUI Client",
    "github-desktop": "GitHub Desktop GUI Client",
    "34": "Simple Sticky Notes Desktop Utility",
    "sticky-notes": "Simple Sticky Notes Desktop Utility",
    "46": "Kubernetes CLI (kubectl) & Cluster Tooling",
    "kubernetes": "Kubernetes CLI (kubectl) & Cluster Tooling",
    "47": "Docker Engine & Docker Compose Container Stack",
    "docker": "Docker Engine & Docker Compose Container Stack",
    "50": "Z-Shell (ZSH) Interactive Shell",
    "zsh": "Z-Shell (ZSH) Interactive Shell",
    "51": "ZSH Shell + Oh-My-Zsh & Auto-suggestions",
    "zsh+config": "ZSH Shell + Oh-My-Zsh & Auto-suggestions"
}

def resolve_profile_tree(item_str):
    clean = item_str.strip().lower()
    if clean.startswith("profile "):
        clean = clean[8:].strip()
    
    # Try importing from profile_tree helper
    try:
        shared_dir = os.path.dirname(os.path.abspath(__file__))
        sys.path.insert(0, shared_dir)
        import profile_tree
        prof, actual_name = profile_tree.resolve_profile(clean)
        if prof and "tree" in prof:
            return prof["tree"][1:] # Return child tree lines
    except Exception:
        pass
    return None

def list_installs():
    db_file = os.path.expanduser("~/.scripts-fixer/install_log.db")
    if not os.path.exists(db_file):
        print("  \033[0;37mNo installation history found.\033[0m")
        return

    conn = sqlite3.connect(db_file)
    cursor = conn.cursor()
    try:
        cursor.execute("SELECT item, MAX(timestamp) FROM installs WHERE status='success' GROUP BY item ORDER BY MAX(timestamp) DESC")
        rows = cursor.fetchall()
        if not rows:
            print("  \033[0;37mNo installation history found.\033[0m")
            return
        
        c_green = "\033[1;32m"
        c_cyan = "\033[1;36m"
        c_yellow = "\033[1;33m"
        c_gray = "\033[0;37m"
        c_bold_white = "\033[1;37m"
        c_reset = "\033[0m"

        print(f"\n  {c_green}Installation History & Under-the-Hood Details ({len(rows)} entries):{c_reset}")
        print(f"  {c_gray}----------------------------------------------------------------------{c_reset}")
        for row in rows:
            item_raw = row[0]
            timestamp_str = row[1][:16].replace('T', ' ')
            
            print(f"    {c_cyan}✔{c_reset} {c_bold_white}{item_raw.ljust(34)}{c_reset} {c_gray}(Last run: {timestamp_str}){c_reset}")
            
            # Check if it is a profile
            tree_lines = resolve_profile_tree(item_raw)
            if tree_lines:
                for line in tree_lines:
                    print(f"      {c_cyan}{line}{c_reset}")
                print("")
            else:
                # Check single tool description
                clean_tool = item_raw.strip().lower()
                if clean_tool in TOOL_DESCRIPTIONS:
                    print(f"      {c_gray}└── {TOOL_DESCRIPTIONS[clean_tool]}{c_reset}\n")
                else:
                    print("")
                    
        print(f"  {c_gray}----------------------------------------------------------------------{c_reset}\n")
    except sqlite3.OperationalError:
        print("  \033[1;31mInstallation database is empty or corrupted.\033[0m")
    finally:
        conn.close()

if __name__ == "__main__":
    list_installs()
