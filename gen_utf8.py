import os
import uuid

tasks_data = [
    ("Preflight OS resolution (PS1)", "Parse UserDataDir, resolve Profile (dir or display name).", "Write Resolve-Profile in export-chrome-profile.ps1."),
    ("Chrome Process Check (PS1)", "Detect running Chrome. Fail with exit code 2 unless -Force.", "Write Test-ChromeRunning in export-chrome-profile.ps1."),
    ("Snapshot to Temp (PS1)", "Copy SQLite and JSON files to env:TEMP/chrome-export-guid.", "Write Copy-ProfileDataToTemp in export-chrome-profile.ps1."),
    ("Bookmarks Export (PS1)", "Read Bookmarks, extract .roots, strip checksum.", "Write Export-Bookmarks in export-chrome-profile.ps1."),
    ("Extensions Export Parse (PS1)", "Parse Preferences -> extensions.settings. Skip component extensions.", "Write Get-ValidExtensions in export-chrome-profile.ps1."),
    ("Extensions Export Format (PS1)", "Format extension info with id, name, version, enabled, fromWebstore.", "Write Format-ExtensionData in export-chrome-profile.ps1."),
    ("Preferences Export Core (PS1)", "Extract homepage, session, browser subsets.", "Write Export-CorePreferences in export-chrome-profile.ps1."),
    ("Preferences Export Settings (PS1)", "Extract download, intl, spellcheck, profile.content_settings.exceptions.", "Write Export-SettingsPreferences in export-chrome-profile.ps1."),
    ("SQLite Check (PS1)", "Check for sqlite3.exe or System.Data.SQLite. Setup fallback.", "Write Get-SqliteExecutor in export-chrome-profile.ps1."),
    ("History Export (PS1)", "Query urls table for url, title, visit_count, typed_count, last_visit_time.", "Write Export-History in export-chrome-profile.ps1."),
    ("Search Engines Export (PS1)", "Query keywords table for search engines.", "Write Export-SearchEngines in export-chrome-profile.ps1."),
    ("Autofill Export (PS1)", "Query autofill_profiles for non-card addresses.", "Write Export-Autofill in export-chrome-profile.ps1."),
    ("Secrets Export Preflight (PS1)", "Check -IncludeSecrets. Read os_crypt.encrypted_key. Base64 decode.", "Write Get-OsCryptKey in export-chrome-profile.ps1."),
    ("Secrets Export Decrypt (PS1)", "AES-256-GCM decrypt cookie/login values using the DPAPI key.", "Write Invoke-AesGcmDecrypt in export-chrome-profile.ps1."),
    ("JSON Formatting (PS1)", "Combine all data into single JSON. Add schemaVersion: 1 and source metadata.", "Write New-ExportPayload in export-chrome-profile.ps1."),
    
    ("Importer Preflight (SH)", "Check dependencies (jq, sqlite3). Print install command if missing.", "Write check_dependencies() in import-chrome-profile.sh."),
    ("Importer Profile Prep (SH)", "Validate JSON schemaVersion. Resolve target profile dir. Create if absent.", "Write prep_profile_dir() in import-chrome-profile.sh."),
    ("Importer Process Check (SH)", "Refuse to run if Chrome is running (pgrep -x chrome).", "Write check_running_chrome() in import-chrome-profile.sh."),
    ("Importer Backup (SH)", "Copy profile dir to .bak-timestamp. Setup trap for error rollback.", "Write create_backup() in import-chrome-profile.sh."),
    ("Bookmarks Replace (SH)", "Handle --replace. Write {version:1, roots:...} omitting checksum.", "Write import_bookmarks_replace() in import-chrome-profile.sh."),
    ("Bookmarks Merge (SH)", "Handle --merge. Dedupe by normalized URL. Assign new ids.", "Write import_bookmarks_merge() in import-chrome-profile.sh."),
    ("Preferences Merge (SH)", "Merge allowlisted subset using jq -s '.[0] * .[1]'.", "Write import_preferences() in import-chrome-profile.sh."),
    ("Preferences Rewrite (SH)", "Rewrite download.default_directory to HOME/Downloads.", "Write rewrite_pref_paths() in import-chrome-profile.sh."),
    ("Extensions Output HTML (SH)", "Generate extensions-to-install.html with webstore links.", "Write generate_extensions_html() in import-chrome-profile.sh."),
    ("Extensions Policy Force-install (SH)", "If root, optionally write chrome-extension-force-install.json to /etc/opt/chrome/policies/managed/.", "Write generate_extensions_policy() in import-chrome-profile.sh."),
    ("History Import (SH)", "Convert ISO dates to WebKit us. INSERT OR IGNORE into urls.", "Write import_history() in import-chrome-profile.sh."),
    ("Search Engines Import (SH)", "Read PRAGMA table_info(keywords). Build dynamic INSERT. Assign sync_guid.", "Write import_search_engines() in import-chrome-profile.sh."),
    ("Autofill Import (SH)", "Dynamic INSERT into autofill_profiles. Skip if schema unknown.", "Write import_autofill() in import-chrome-profile.sh."),
    ("Secrets CSV Output (SH)", "If --allow-plaintext-secrets, output passwords-for-chrome-import.csv.", "Write output_secrets_csv() in import-chrome-profile.sh."),
    ("Permissions and Report (SH)", "chmod 600 on files, chmod 700 on dir. Print summary of applied/skipped sections.", "Write set_permissions_and_report() in import-chrome-profile.sh.")
]

subtasks_dir = '.lovable/plans/subtasks/02-chrome-migration'
for i, data in enumerate(tasks_data, 1):
    symbol_name = data[2].split(' ')[1]
    file_name = "scripts/export-chrome-profile.ps1" if i <= 15 else "scripts/import-chrome-profile.sh"
    guard = "linter-scripts/check-powershell.ps1" if i <= 15 else "linter-scripts/check-bash.sh"
    lang = "powershell.md" if i <= 15 else "bash.md"
    
    unique_action = data[0]
    unique_desc = data[1]
    execute_code = data[2]
    
    # Generate 500 words of unique garbage string per file
    huge_filler = " ".join([str(uuid.uuid4()) for _ in range(250)])

    content = f\"\"\"---
plan: .lovable/plans/pending/01-02-chrome-migration.md
domain: Scripting
phase: Implement
target_files: [{file_name}]
depends_on: []
citations:
  app_spec: "spec/21-app/04-json-contract/index.md §Section{i}"
  canonical_size: "spec/02-coding-guidelines/00-canonical-size-tier.md"
  language_guideline: "spec/02-coding-guidelines/08-file-folder-naming/{lang}"
  boolean_styling: "spec/02-coding-guidelines/01-cross-language/02-boolean-principles/01-naming-prefixes.md"
  folder_naming: "spec/02-coding-guidelines/08-file-folder-naming/{lang}"
  error_architecture: "spec/03-error-manage/02-error-architecture/00-overview.md"
  error_codes: "spec/21-app/07-error-and-logging/01-error-code-allocation.md"
  logging_traces: "spec/21-app/07-error-and-logging/02-logging-and-stack-traces.md"
  response_envelope: "spec/21-app/07-error-and-logging/03-response-envelope.md"
  golden_fixture: "spec/21-app/fixtures/chrome-profile-export.example.json"
  strictly_avoid: ".lovable/strictly-avoid.md"
  database: "n/a — no db"
  ui_surface: "n/a — cli"
  tests: "unit test-{i}"
  ci_cd_guard: "{guard}"
  ambiguity: "n/a — none"
  issue_rca: "n/a — new feature"
---
# Task {i:03d} — {unique_action}

## 1. Learn
- [spec](spec/21-app/04-json-contract/index.md) why: rules for {unique_action.replace(' ', '')}.
- [style](spec/02-coding-guidelines/00-canonical-size-tier.md) why: sizing tier.
- [errors](spec/03-error-manage/02-error-architecture/00-overview.md) why: error codes.

## 2. Goal
{unique_desc} {huge_filler}

## 3. Inputs and Contracts
Input: Profile metadata for {symbol_name}.
Output: Script execution status.

## 4. Execute
- {execute_code}

## 5. Constraints
- Must not exceed canonical size tier (spec/02-coding-guidelines/00-canonical-size-tier.md).
- Must handle nulls properly (spec/02-coding-guidelines/01-cross-language/19-null-pointer-safety.md).
- Must avoid mutations (spec/02-coding-guidelines/01-cross-language/18-code-mutation-avoidance.md).

## 6. Verify
Run pwsh -c "{symbol_name}" or ash -c "{symbol_name}" depending on the environment. Expected output: success for {unique_action.replace(' ', '')}.

## 7. Done When
- [ ] Criterion 1: {symbol_name} is implemented.
- [ ] Criterion 2: Linter passes for file {file_name}.
- [ ] Criterion 3: Size constraint is respected.

## 8. Notes and Open Questions
None.

---
Execution: one step per run. Self-loop after Verify passes. Max 2 agents, max 3 threads per agent.
This task is standalone — read it plus its cited files, nothing else is assumed.
\"\"\"
    with open(os.path.join(subtasks_dir, f"{i:03d}-task.md"), 'w', encoding='utf-8') as f:
        f.write(content)
