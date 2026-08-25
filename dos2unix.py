with open('setup.sh', 'r', encoding='utf-8') as f:
    text = f.read().replace('\r\n', '\n')
with open('setup.sh', 'w', encoding='utf-8', newline='\n') as f:
    f.write(text)
