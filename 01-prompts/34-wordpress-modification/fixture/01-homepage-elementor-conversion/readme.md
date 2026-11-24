# Task 01: Homepage Elementor Conversion

This task-scoped directory modernizes the target WordPress homepage into native Elementor JSON structures (`_elementor_data`).

## Feature Stack
1. **3-Stage Base64 Security:** Encrypts Application Passwords in `wp-credentials.json` and asserts connection via `GET /wp-json/wp/v2/users/me`.
2. **Pre-Flight Draft Backup:** Clones original page to `<title> - Backup [Timestamp]` with status `draft` in `backups.json`.
3. **Elementor Mapping:** Transpiles page sections to Flexbox containers, heading, text, button, and image widgets.
4. **Scoped CSS & Lowercase IDs:** Assigns semantic lowercase IDs (`settings._element_id`) and scoped CSS in `settings.custom_css`.
5. **Visual Diff Verification:** Headless browser capture and pixel diffing in `assets/visual-diff.png`.

## File References
- Credentials store: `wp-credentials.json` (.gitignore enforced)
- Backup registry: `backups.json`
- Ingestion guide: `what-to-read.md`
- Trace: `conversation/01-user-request.md`
