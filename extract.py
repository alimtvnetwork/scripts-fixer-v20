import re

with open('assets/linux-manage-2024-v2.one', 'rb') as f:
    data = f.read()

ascii_text = re.sub(b'[^\x20-\x7E\r\n\t]+', b'\n', data).decode('ascii', errors='ignore')

with open('assets/extracted.txt', 'w', encoding='utf-8') as f:
    for line in ascii_text.split('\n'):
        if len(line.strip()) > 5: f.write(line.strip() + '\n')
