import json

with open("version.json", "r", encoding="utf-8") as f:
    data = json.load(f)

v = data.get("version", "1.0.0")
parts = v.split(".")
if len(parts) == 3:
    parts[1] = str(int(parts[1]) + 1)
    parts[2] = "0"
    new_v = ".".join(parts)
else:
    new_v = v + ".1"

data["version"] = new_v

with open("version.json", "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2)

print(f"Bumped version from {v} to {new_v}")
