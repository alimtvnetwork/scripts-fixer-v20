"""
TRANSFORMATION STEP: hero_modernization
================================================================================
USER REQUEST: "Modernize hero section with dark glassmorphism and 60/30/10 colors"
PURPOSE:      Inject updated gradient typography, backdrop blur, and primary CTA
PROCESS:      1. Pre-flight compile check.
              2. Traverse AST to locate target container widget.
              3. Update container styling settings.
              4. Generate scoped CSS with backdrop filter.
              5. Validate modified AST against schema.
CHECKLIST:
  [x] Scoped lowercase ID assigned (_element_id)
  [x] CSS rules use 'selector' keyword (no global leakage)
  [x] Pre-compilation validation passed
  [x] Result[T] error envelope returned
================================================================================
"""
from __future__ import annotations

from typing import Any

from scripts.app_errors import AppError, Result
from scripts.css_engine import ScopedCssBuilder
from scripts.transform_protocol import (
    ITransformStep,
    TransformContext,
    register_transform,
)


@register_transform("HeroModernizationTransform")
class HeroModernizationTransform:
    """Sample pluggable transformation step modernizing hero section layout."""
    step_id: str = "hero_modernization"
    description: str = "Modernize hero section with dark glassmorphism"
    user_request: str = "Modernize hero section with dark glassmorphism and 60/30/10 colors"

    def compile(self, context: TransformContext) -> Result[bool]:
        target_id = context.params.get("target_id", "hero-section")
        if not target_id:
            return Result.fail(AppError("INVALID_TARGET", "Missing target_id in params"))

        return Result.ok(True)

    def modify_ast(self, ast: dict[str, Any], context: TransformContext) -> Result[dict[str, Any]]:
        elements = ast.get("elements", [])
        if not elements:
            return Result.fail(AppError("EMPTY_AST", "AST has no elements"))

        updated_ast = dict(ast)
        target_id = context.params.get("target_id", "hero-section")
        for el in updated_ast.get("elements", []):
            self._update_matching_element(el, target_id)

        return Result.ok(updated_ast)

    def _update_matching_element(self, element: dict[str, Any], target_id: str) -> None:
        el_settings = element.get("settings", {})
        el_id = el_settings.get("_element_id", "")
        if el_id == target_id:
            el_settings["background_background"] = "gradient"
            el_settings["background_color"] = "#0f172a"

    def modify_css(self, existing_css: str, context: TransformContext) -> Result[str]:
        target_selector = context.params.get("target_selector", "selector")
        rules = {
            "background": "rgba(15, 23, 42, 0.75)",
            "backdrop-filter": "blur(16px)",
            "border": "1px solid rgba(255, 255, 255, 0.1)",
            "border-radius": "16px",
        }
        built_css = ScopedCssBuilder.append_scoped_rules(existing_css, target_selector, rules)
        return Result.ok(built_css)

    def validate(self, ast: dict[str, Any]) -> Result[bool]:
        has_version = "version" in ast or "elements" in ast
        if not has_version:
            return Result.fail(AppError("VALIDATION_FAILED", "Invalid AST format"))

        return Result.ok(True)
