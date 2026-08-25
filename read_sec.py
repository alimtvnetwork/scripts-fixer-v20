with open('ubuntu-installation-guide/02-ubuntu-manage-v2.md', 'r', encoding='utf-8') as f:
    lines = f.readlines()

in_section = False
for line in lines:
    if line.startswith('## VMware Open VM Tools'):
        in_section = True
    elif in_section and line.startswith('## '):
        break
    if in_section:
        print(line, end='')
