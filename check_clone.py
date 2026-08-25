import os
import glob
import hashlib

def hash_file(filepath):
    lines = []
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.readlines()
        for i, line in enumerate(content):
            if i < 3: continue
            if line.startswith('**Plan') or line.startswith('**Domain') or line.startswith('**Target Files') or line.startswith('**Depends On'): continue
            lines.append(line)
    return hashlib.sha256(''.join(lines).encode('utf-8')).hexdigest()[:12]

buckets = {}
for f in glob.glob('.lovable/plans/subtasks/02-chrome-migration/*.md'):
    h = hash_file(f)
    buckets[h] = buckets.get(h, 0) + 1

max_count = max(buckets.values())
print(f"Max items in bucket: {max_count}")
