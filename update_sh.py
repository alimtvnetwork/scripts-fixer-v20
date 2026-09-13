import re

with open('scripts/run.sh', 'r', encoding='utf-8') as f:
    sh = f.read()

# Add to case statement in scripts/run.sh
cases = '''    "export-config")
        APP=$1
        mkdir -p ./configs
        if [ "$APP" = "qtorrent" ]; then cp -r ~/.config/qBittorrent ./configs/qtorrent; fi
        if [ "$APP" = "utorrent" ]; then cp -r ~/.config/uTorrent ./configs/utorrent 2>/dev/null || cp -r ~/.utorrent ./configs/utorrent 2>/dev/null; fi
        if [ "$APP" = "vscode" ]; then cp -r ~/.config/Code/User ./configs/vscode; fi
        echo "Exported config for $APP"
        ;;
    "import-config")
        APP=$1
        if [ "$APP" = "qtorrent" ]; then cp -r ./configs/qtorrent ~/.config/qBittorrent; fi
        if [ "$APP" = "utorrent" ]; then cp -r ./configs/utorrent ~/.config/uTorrent; fi
        if [ "$APP" = "vscode" ]; then cp -r ./configs/vscode ~/.config/Code/User; fi
        echo "Imported config for $APP"
        ;;
'''
sh = sh.replace('case "$COMMAND" in', 'case "$COMMAND" in\n' + cases, 1)

# Add to help output
help_lines = '''    printf "    %-44s ${MUTED}%s${TEXT}\\n" "./run.sh export-config <app>" "Export app config (qtorrent, utorrent, vscode)"
    printf "    %-44s ${MUTED}%s${TEXT}\\n" "./run.sh import-config <app>" "Import app config (qtorrent, utorrent, vscode)"
'''
sh = sh.replace('printf "    %-44s ${MUTED}%s${TEXT}\\n" "./run.sh <command> -h" "Show detailed help for a command"', 
                'printf "    %-44s ${MUTED}%s${TEXT}\\n" "./run.sh <command> -h" "Show detailed help for a command"\n' + help_lines, 1)

with open('scripts/run.sh', 'w', encoding='utf-8', newline='\n') as f:
    f.write(sh)

print('Updated scripts/run.sh')
