import os
import re

run_sh = "scripts/run.sh"
with open(run_sh, "r", encoding="utf-8") as f:
    content = f.read()

footer_fn = """show_footer() {
    local VER="unknown"
    if [ -f "version.json" ]; then
        VER=$(grep -o '"version": "[^"]*"' version.json | cut -d'"' -f4)
    fi
    local SHA=$(git rev-parse --short=12 HEAD 2>/dev/null || echo "unknown")
    local BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
    local REMOTE=$(git config --get remote.origin.url 2>/dev/null)
    local TIME=$(git log -1 --format=%cd --date=local 2>/dev/null || echo "unknown")

    echo -e ""
    echo -ne "  ${MAGENTA}scripts-fixer v${VER}${NC} ${DARK_GRAY}|${NC} "
    echo -ne "${CYAN}git ${SHA} (${BRANCH})${NC} ${DARK_GRAY}|${NC} "
    echo -e "${YELLOW}${TIME}${NC}"
    if [ ! -z "$REMOTE" ]; then
        echo -e "  ${DARK_GRAY}repo: ${NC}${REMOTE}"
    fi
    echo -e ""
}

"""

# Insert show_footer after show_profile_help
content = content.replace("show_profile_help() {", footer_fn + "show_profile_help() {")

# To ensure it runs at the end of all installations, we can just append it at the end of the file
# and also replace exit 0 with show_footer; exit 0

content = content.replace("exit 0", "show_footer\n    exit 0")
if "show_footer" not in content[-50:]:
    content += "\nshow_footer\n"

with open(run_sh, "w", encoding="utf-8", newline='\n') as f:
    f.write(content)

print("run.sh updated.")
