import json

# Update registry
reg_file = "scripts/registry.json"
with open(reg_file, "r") as f:
    reg = json.load(f)

reg["72"] = "72-install-git-lfs"
reg["73"] = "73-install-gh"
reg["74"] = "74-install-python2"
reg["75"] = "75-install-yarn"

with open(reg_file, "w") as f:
    json.dump(reg, f, indent=4)

# Update keywords
kw_file = "scripts/shared/install-keywords.json"
with open(kw_file, "r") as f:
    kw = json.load(f)

kw["git-lfs"] = {"id": "72"}
kw["gh"] = {"id": "73"}
kw["python2"] = {"id": "74"}
kw["yarn"] = {"id": "75"}
kw["zsh"] = {"id": "profile", "args": ["zsh"]}
kw["zsh+config"] = {"id": "profile", "args": ["zsh+config"]}

with open(kw_file, "w") as f:
    json.dump(kw, f, indent=4)

print("Updated registry and keywords.")
