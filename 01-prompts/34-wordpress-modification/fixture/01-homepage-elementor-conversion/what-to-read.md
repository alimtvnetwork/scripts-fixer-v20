# What to Read: 01-homepage-elementor-conversion

Context and memory guide for downstream AI agents:

1. **Authentication:** Decrypt credentials using `scripts/wp_auth.py` and run connection probe before executing modifications.
2. **Backups:** Never mutate a page without an entry in `backups.json`.
3. **Elementor Schema:** Use builders in `scripts/elementor_schema.py`. Every element must have a lowercase hyphen-separated `_element_id`.
4. **Theme Scope:** Only edit `wp/v2/pages` for page content. Query `wp/v2/elementor_library` for headers, footers, or archives.
