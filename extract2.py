import re

with open('assets/linux-manage-2024-v2.one', 'rb') as f:
    data = f.read()
    
# Try ascii
text = data.decode('ascii', errors='ignore')
lines = text.split('\n')
valid_lines = []
for line in lines:
    line = line.strip()
    # Find anything that looks like a shell command or alias
    if 'sudo ' in line or 'apt ' in line or 'apt-fast ' in line or 'alias ' in line or 'chmod ' in line or 'echo ' in line or 'tar ' in line or 'ln -s ' in line:
        # clean non printable
        cleaned = ''.join(c for c in line if 31 < ord(c) < 127)
        if cleaned:
            valid_lines.append(cleaned)

with open('commands_extracted.txt', 'w', encoding='utf-8') as out:
    for cmd in sorted(list(set(valid_lines))):
        out.write(cmd + '\n')
