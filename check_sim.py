import glob
import difflib

def get_content(filepath):
    lines = []
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.readlines()
        for i, line in enumerate(content):
            if i < 3: continue
            if line.startswith('**Plan') or line.startswith('**Domain') or line.startswith('**Target Files') or line.startswith('**Depends On'): continue
            lines.append(line)
    return "".join(lines)

files = glob.glob('.lovable/plans/subtasks/02-chrome-migration/*.md')
max_sim = 0
for i in range(len(files)):
    for j in range(i+1, len(files)):
        c1 = get_content(files[i])
        c2 = get_content(files[j])
        sim = difflib.SequenceMatcher(None, c1, c2).ratio()
        if sim > max_sim:
            max_sim = sim
print(f"Max similarity: {max_sim*100:.2f}%")
