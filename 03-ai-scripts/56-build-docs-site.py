#!/usr/bin/env python3
"""
56-build-docs-site.py
Builds the standalone docs-site.zip archive for GitMap Help Dashboard (gitmap hd).
Extracts command documentation, packages into docs-site/dist/, and creates docs-site.zip.
"""

import os
import sys
import zipfile
import json
import html

def build_docs_site(repo_dir: str, output_zip_path: str):
    helpdoc_dir = os.path.join(repo_dir, "cli", "helpdoc")
    if not os.path.isdir(helpdoc_dir):
        print(f"Error: {helpdoc_dir} not found")
        sys.exit(1)

    commands = []
    for entry in sorted(os.listdir(helpdoc_dir)):
        if entry.endswith(".md") and entry != "readme.md":
            cmd_name = entry[:-3]
            file_path = os.path.join(helpdoc_dir, entry)
            try:
                with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
                    content = f.read()
            except Exception:
                continue

            lines = [line.strip() for line in content.splitlines() if line.strip()]
            desc = lines[0] if lines else "GitMap command"
            if desc.startswith("#"):
                desc = desc.lstrip("#").strip()

            commands.append({
                "name": cmd_name,
                "summary": desc,
                "content": content[:1200]
            })

    index_html = f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>GitMap — Documentation & CLI Guide</title>
  <style>
    :root {{
      --bg: #1a1b26;
      --card-bg: #24283b;
      --text: #c0caf5;
      --heading: #7aa2f7;
      --accent: #bb9af7;
      --green: #9ece6a;
      --border: #414868;
    }}
    * {{ box-sizing: border-box; margin: 0; padding: 0; }}
    body {{
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, monospace;
      background: var(--bg);
      color: var(--text);
      line-height: 1.6;
      padding: 2rem;
    }}
    header {{
      max-width: 1100px;
      margin: 0 auto 2rem;
      border-bottom: 1px solid var(--border);
      padding-bottom: 1rem;
    }}
    h1 {{ color: var(--heading); font-size: 2rem; margin-bottom: 0.5rem; }}
    .subtitle {{ color: #565f89; font-size: 1rem; }}
    .search-box {{
      max-width: 1100px;
      margin: 0 auto 2rem;
    }}
    input[type="text"] {{
      width: 100%;
      padding: 0.8rem 1.2rem;
      background: var(--card-bg);
      border: 1px solid var(--border);
      border-radius: 8px;
      color: #fff;
      font-size: 1.1rem;
      outline: none;
    }}
    input[type="text"]:focus {{
      border-color: var(--heading);
      box-shadow: 0 0 10px rgba(122, 162, 247, 0.3);
    }}
    .grid {{
      max-width: 1100px;
      margin: 0 auto;
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
      gap: 1.5rem;
    }}
    .card {{
      background: var(--card-bg);
      border: 1px solid var(--border);
      border-radius: 8px;
      padding: 1.2rem;
      transition: transform 0.15s ease, border-color 0.15s ease;
    }}
    .card:hover {{
      transform: translateY(-2px);
      border-color: var(--heading);
    }}
    .card-title {{
      color: var(--green);
      font-size: 1.2rem;
      font-weight: bold;
      margin-bottom: 0.5rem;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }}
    .badge {{
      font-size: 0.75rem;
      padding: 0.2rem 0.5rem;
      background: #1f2335;
      border: 1px solid var(--border);
      border-radius: 4px;
      color: var(--accent);
    }}
    .card-desc {{
      color: #a9b1d6;
      font-size: 0.95rem;
      margin-bottom: 1rem;
    }}
    pre {{
      background: #16161e;
      padding: 0.6rem;
      border-radius: 4px;
      overflow-x: auto;
      font-size: 0.85rem;
      color: #7dcfff;
    }}
  </style>
</head>
<body>
  <header>
    <h1>GitMap — Unified CLI & Developer Companion</h1>
    <div class="subtitle">Complete offline documentation & command reference ({len(commands)} commands indexed)</div>
  </header>

  <div class="search-box">
    <input type="text" id="searchInput" placeholder="Search commands, flags, keywords (Press / to focus)..." autofocus>
  </div>

  <div class="grid" id="commandGrid">
  </div>

  <script>
    const commands = {json.dumps(commands)};
    const grid = document.getElementById("commandGrid");
    const searchInput = document.getElementById("searchInput");

    function render(list) {{
      grid.innerHTML = "";
      if (list.length === 0) {{
        grid.innerHTML = '<div style="color: #565f89; grid-column: 1/-1; text-align: center; padding: 2rem;">No matching commands found.</div>';
        return;
      }}
      list.forEach(cmd => {{
        const card = document.createElement("div");
        card.className = "card";
        card.innerHTML = `
          <div class="card-title">
            <span>gitmap ${{cmd.name}}</span>
            <span class="badge">CLI</span>
          </div>
          <div class="card-desc">${{cmd.summary}}</div>
          <pre><code>gitmap ${{cmd.name}} --help</code></pre>
        `;
        grid.appendChild(card);
      }});
    }}

    render(commands);

    searchInput.addEventListener("input", (e) => {{
      const query = e.target.value.toLowerCase().trim();
      if (!query) {{
        render(commands);
        return;
      }}
      const filtered = commands.filter(c =>
        c.name.toLowerCase().includes(query) ||
        c.summary.toLowerCase().includes(query) ||
        c.content.toLowerCase().includes(query)
      );
      render(filtered);
    }});

    window.addEventListener("keydown", (e) => {{
      if (e.key === "/" && document.activeElement !== searchInput) {{
        e.preventDefault();
        searchInput.focus();
      }}
    }});
  </script>
</body>
</html>
"""

    # Read dynamic version from version.json if available
    version_val = "6.700.0"
    v_file = os.path.join(repo_dir, "version.json")
    if os.path.exists(v_file):
        try:
            with open(v_file, "r", encoding="utf-8") as vf:
                v_data = json.load(vf)
                version_val = v_data.get("Version", version_val)
        except Exception:
            pass

    os.makedirs(os.path.dirname(os.path.abspath(output_zip_path)), exist_ok=True)
    with zipfile.ZipFile(output_zip_path, "w", zipfile.ZIP_DEFLATED) as zf:
        zf.writestr("docs-site/dist/index.html", index_html.encode("utf-8"))
        zf.writestr("docs-site/index.html", index_html.encode("utf-8"))
        zf.writestr("docs-site/dist/manifest.json", json.dumps({"commandsCount": len(commands), "version": version_val}, indent=2).encode("utf-8"))

    print(f"Successfully packaged {output_zip_path} ({len(commands)} commands indexed, size: {os.path.getsize(output_zip_path)} bytes)")

if __name__ == "__main__":
    repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
    dist_zip = os.path.join(repo_root, "cli", "bin", "docs-site.zip")
    if len(sys.argv) > 1:
        dist_zip = sys.argv[1]
    build_docs_site(repo_root, dist_zip)
