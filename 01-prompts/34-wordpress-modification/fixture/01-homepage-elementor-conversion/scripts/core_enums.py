"""scripts/core_enums.py — Strongly typed enums for WordPress & Elementor operations."""

from enum import IntEnum, StrEnum


class ElementorWidgetType(StrEnum):
    CONTAINER = "container"
    HEADING = "heading"
    TEXT_EDITOR = "text-editor"
    BUTTON = "button"
    IMAGE = "image"
    ICON_BOX = "icon-box"
    FORM = "form"


class PostStatusType(StrEnum):
    PUBLISHED = "publish"
    DRAFT = "draft"
    PENDING = "pending"
    PRIVATE = "private"


class ExitCodeType(IntEnum):
    SUCCESS = 0
    GENERAL_ERROR = 1
    INVALID_USAGE = 2
    AUTH_FAILED = 3
