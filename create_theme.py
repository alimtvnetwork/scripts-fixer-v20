import os
import json

theme = {
  "colors": {
    "primary": "Magenta",
    "secondary": "Cyan",
    "accent": "Yellow",
    "muted": "Gray", 
    "error": "Red",
    "text": "White"
  }
}

os.makedirs("scripts/shared", exist_ok=True)
with open("scripts/shared/theme.json", "w", encoding="utf-8") as f:
    json.dump(theme, f, indent=2)

print("Created theme.json")
