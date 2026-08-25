import string
with open('assets/linux-manage-2024-v2.one', 'rb') as f:
    data = f.read()
    
# Extract printable utf-16 characters or ascii
# Usually OneNote stores text in UTF-16LE
try:
    text = data.decode('utf-16le', errors='ignore')
    # Filter to readable characters (basic heuristic)
    printable = set(string.printable)
    cleaned = ''.join(filter(lambda x: x in printable or x > '\x1f', text))
    with open('extracted_utf16.txt', 'w', encoding='utf-8') as out:
        out.write(cleaned)
except Exception as e:
    print('utf16 failed', e)

# ASCII
try:
    text = data.decode('ascii', errors='ignore')
    printable = set(string.printable)
    cleaned = ''.join(filter(lambda x: x in printable, text))
    with open('extracted_ascii.txt', 'w', encoding='utf-8') as out:
        out.write(cleaned)
except Exception as e:
    print('ascii failed', e)
