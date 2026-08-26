with open("scripts/run.sh", "r", encoding="utf-8") as f:
    lines = f.readlines()
print("".join(lines[-30:]))
