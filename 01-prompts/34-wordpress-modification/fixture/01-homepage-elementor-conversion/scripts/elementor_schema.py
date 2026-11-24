"""scripts/elementor_schema.py — Modular Elementor JSON component generators."""

import uuid


def generate_element_id() -> str:
    return uuid.uuid4().hex[:7]


def build_container(element_id: str, css_classes: str, custom_css: str, children: list[dict]) -> dict:
    return {
        "id": generate_element_id(),
        "elType": "container",
        "isInner": False,
        "settings": {
            "_element_id": element_id,
            "_css_classes": css_classes,
            "custom_css": custom_css,
            "flex_direction": "column"
        },
        "elements": children
    }


def build_heading(title: str, header_size: str, element_id: str, css_classes: str) -> dict:
    return {
        "id": generate_element_id(),
        "elType": "widget",
        "widgetType": "heading",
        "settings": {
            "_element_id": element_id,
            "_css_classes": css_classes,
            "title": title,
            "header_size": header_size
        }
    }


def build_text_editor(editor_html: str, element_id: str, css_classes: str) -> dict:
    return {
        "id": generate_element_id(),
        "elType": "widget",
        "widgetType": "text-editor",
        "settings": {
            "_element_id": element_id,
            "_css_classes": css_classes,
            "editor": editor_html
        }
    }


def build_button(text: str, url: str, button_type: str, element_id: str, css_classes: str) -> dict:
    return {
        "id": generate_element_id(),
        "elType": "widget",
        "widgetType": "button",
        "settings": {
            "_element_id": element_id,
            "_css_classes": css_classes,
            "text": text,
            "link": {"url": url},
            "button_type": button_type
        }
    }


def build_image(image_url: str, image_id: int, element_id: str, css_classes: str) -> dict:
    return {
        "id": generate_element_id(),
        "elType": "widget",
        "widgetType": "image",
        "settings": {
            "_element_id": element_id,
            "_css_classes": css_classes,
            "image": {"url": image_url, "id": image_id}
        }
    }


def build_icon_box(title: str, desc: str, icon_name: str, element_id: str, css_classes: str) -> dict:
    return {
        "id": generate_element_id(),
        "elType": "widget",
        "widgetType": "icon-box",
        "settings": {
            "_element_id": element_id,
            "_css_classes": css_classes,
            "title_text": title,
            "description_text": desc,
            "selected_icon": {"value": icon_name, "library": "fa-solid"}
        }
    }
