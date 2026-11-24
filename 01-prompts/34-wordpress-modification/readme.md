# Universal WordPress & Elementor Modification Prompts (`34-wordpress-modification`)

This directory hosts the canonical, standalone execution prompt for WordPress website modernizations, page conversions to native Elementor JSON structures, and REST API automation.

## Prompt Index

- [`01-universal-wordpress-elementor-modification-prompt.md`](01-universal-wordpress-elementor-modification-prompt.md) — Master Standalone Prompt (v2.0.0). Features 3-stage base64 credential encryption, pre-flight draft backup invariants (`backups.json`), Elementor component best-fit mapping with semantic lowercase hyphenated IDs (`_element_id`), BEM classes (`_css_classes`), scoped CSS (`custom_css`), visual screenshot diff comparisons (`assets/`), Muse architectural guidance, REST API self-healing error matrix, and site-specific isolation under `sites/<domain_slug>/`.
- [`02-universal-elementor-finetune-pixel-perfect-loop-prompt.md`](02-universal-elementor-finetune-pixel-perfect-loop-prompt.md) — Master Standalone Prompt for Elementor Fine-Tuning & Pixel-Perfect Screen Comparison. Runs an autonomous 100–300 iteration comparison loop across 6–8 viewports (`screens.json`), headless Pillow visual diffing (`visual_diff.py`), REST API pre-flight draft backup snapshots (`backups.json`), automated screenshot cleanup, and AI memory persistence.
- [`elementor-modify-pixel-perfect-loop.md`](elementor-modify-pixel-perfect-loop.md) — Raw verbatim GitHub Gist source prompt.
- [`../35-universal-single-file-prompts/02-universal-wordpress-elementor-modification-prompt.md`](../35-universal-single-file-prompts/02-universal-wordpress-elementor-modification-prompt.md) — 100% sovereign single-file standalone edition with embedded launchers, enums, constants, REST client, and visual diffing code for direct human/AI copy-pasting.
- [`../35-universal-single-file-prompts/06-universal-elementor-finetune-pixel-perfect-loop-prompt.md`](../35-universal-single-file-prompts/06-universal-elementor-finetune-pixel-perfect-loop-prompt.md) — 100% sovereign single-file edition of the pixel-perfect fine-tuning loop prompt.

## Reference Fixture
- [`fixture/01-homepage-elementor-conversion/`](fixture/01-homepage-elementor-conversion/) — Complete, runnable reference implementation featuring working launchers (`run.ps1`, `run.sh`), 3-stage base64 credential store, backup registry, Elementor widget builders, and visual diff analysis.

## Key Capabilities & Architecture

1. **Zero-Data-Loss Invariant:** Automatically creates a complete duplicate draft backup `<title> - Backup [Timestamp]` via the WordPress REST API before mutating any post or page.
2. **3-Stage Base64 Credential Security:** Transforms Application Passwords through three sequential base64 encoding passes, splits the string across three fields (`part_a`, `part_b`, `part_c`) in `wp-credentials.json` (.gitignore enforced), and confirms connectivity with `GET /wp-json/wp/v2/users/me`.
3. **Structured Elementor Conversion:** Maps legacy HTML, widgets, and mockups into modern Elementor flexbox containers and widgets with structured, lowercase hyphenated IDs (`#hero-section`, `#hero-cta-btn`) and BEM classes.
4. **Muse Architectural Guidance:** Clear conceptual primers explaining WordPress postmeta layout, serialized JSON `_elementor_data`, and Gutenberg-to-Elementor migrations for weak AIs.
5. **Visual Diff Verification:** Captures before and after screenshots of the live site, computes mismatch percentages via Pillow `ImageChops`, verifies layout alignment against target mockups in `assets/`, and iteratively tunes CSS.
6. **Theme Builder vs Page Scope:** Explicitly isolates standard page modifications from global Theme Builder templates (Header, Footer, Single, Archive, 404).
