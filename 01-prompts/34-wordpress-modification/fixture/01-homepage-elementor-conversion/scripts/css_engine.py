"""Scoped CSS builder and design token engine for Elementor components."""
from __future__ import annotations

import re


class ScopedCssBuilder:
    """Utility engine for scoped Elementor CSS styling and token replacement."""

    @staticmethod
    def format_rule_block(selector: str, rules: dict[str, str]) -> str:
        declarations = [f"  {k}: {v};" for k, v in rules.items()]
        decl_body = "\n".join(declarations)
        return f"{selector} {{\n{decl_body}\n}}"

    @classmethod
    def append_scoped_rules(cls, existing_css: str, selector: str, rules: dict[str, str]) -> str:
        new_block = cls.format_rule_block(selector, rules)
        clean_css = existing_css.strip()
        if not clean_css:
            return new_block

        return f"{clean_css}\n\n{new_block}"

    @classmethod
    def replace_scoped_css(cls, existing_css: str, selector: str, new_css: str) -> str:
        pattern = re.compile(rf"{re.escape(selector)}\s*\{{[^}}]*\}}", re.MULTILINE)
        has_match = bool(pattern.search(existing_css))
        if has_match:
            return pattern.sub(new_css.strip(), existing_css).strip()

        return cls.append_scoped_rules(existing_css, selector, {})

    @staticmethod
    def merge_design_tokens(css: str, tokens: dict[str, str]) -> str:
        result = css
        for key, value in tokens.items():
            token_pattern = rf"var\(--{re.escape(key)}\)|__TOKEN_{re.escape(key.upper())}__"
            result = re.sub(token_pattern, value, result)

        return result
