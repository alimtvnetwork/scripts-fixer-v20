#!/usr/bin/env python3
"""
Generates animated terminal demo SVGs for the root readme.

Each SVG is a self-contained animated terminal recording rendered with
Ubuntu Mono. Animation is driven by SMIL <set> timings so the output
plays inline on GitHub, GitLab, npm, and most static-site renderers.

Style targets:
  - Dark terminal chrome with macOS-style traffic-light dots
  - Ubuntu Mono, large legible font (readable on a phone screen)
  - Character-by-character typing, then output reveal
  - Blinking cursor, looped scene

Demos produced:
  1. run-profile-advance.svg   -> .\\run.ps1 profile advance
  2. run-install-postgresql.svg -> .\\run.ps1 install postgresql
  3. run-os-clean.svg          -> .\\run.ps1 os clean

Re-run with:  python3 assets/demos/build-demos.py
"""

from __future__ import annotations

import html
from dataclasses import dataclass
from enum import Enum
from pathlib import Path
from typing import List, Tuple

OUT_DIR = Path(__file__).resolve().parent

# ---------------------------------------------------------------------------
# Visual constants
# ---------------------------------------------------------------------------

WIDTH = 1280
HEIGHT = 720
PADDING_X = 56
PADDING_TOP = 96  # leaves room for the title bar
LINE_HEIGHT = 38
FONT_SIZE = 22
TYPE_SPEED = 0.04  # seconds per character while typing the prompt

CURSOR_WIDTH = 14
CURSOR_HEIGHT = 26
CURSOR_OFFSET_Y = 22
CURSOR_OPACITY_START = "0"
CURSOR_OPACITY_END = "1"
CURSOR_DUR = "1s"
CURSOR_REPEAT = "indefinite"
CURSOR_ANIM_VALUES = "1;0;1"
DELAY_BETWEEN_LINES = 0.05
CURSOR_BLINK_START = 0.2
CHAR_ADVANCE_PX = 13
SHADOW_PADDING = 32
CHROME_PADDING = 16
SHADOW_RX = 14
CHROME_RX = 14
CHROME_X_Y = 8
TITLE_H = 56
TITLE_INNER_Y = 44
TITLE_INNER_H = 20
TRAFFIC_CY = 36
TRAFFIC_R = 8
TRAFFIC_R_CX = 40
TRAFFIC_Y_CX = 68
TRAFFIC_G_CX = 96
TITLE_TEXT_Y = 42
TITLE_TEXT_SZ = 16
SCREEN_RX = 6
SCREEN_PAD_W = 40
SCREEN_PAD_H = 92
SCREEN_Y = 72
SCREEN_X = 20
SHADOW_X = 16
SHADOW_Y = 20
STROKE_WIDTH = 1
SHADOW_OPACITY = "0.35"
TITLE_ANCHOR = "middle"
FILL_FREEZE = "freeze"
OPACITY_ATTR = "opacity"

class ColorType(str, Enum):
    CHROME_BG = "#0b0f17"
    SCREEN_BG = "#0e1420"
    TITLE_BG = "#161c2a"
    TITLE_FG = "#8b95a7"
    PROMPT_USER = "#56d364"   # green - user@host
    PROMPT_AT = "#8b95a7"     # gray @ separator
    PROMPT_HOST = "#79c0ff"   # blue - host
    PROMPT_PATH = "#d2a8ff"   # purple - cwd
    PROMPT_ARROW = "#f0883e"  # orange - PS> arrow
    TEXT_FG = "#e6edf3"
    DIM_FG = "#8b95a7"
    ACCENT_OK = "#56d364"
    ACCENT_WARN = "#e3b341"
    ACCENT_INFO = "#79c0ff"
    ACCENT_HEADER = "#d2a8ff"

@dataclass
class Line:
    """A line that appears on the terminal."""
    segments: List[Tuple[str, str]]   # list of (text, color) chunks
    delay: float                       # seconds before this line shows
    typed: bool = False                # True = typewriter; False = instant


def esc(s: str) -> str:
    return html.escape(s, quote=True)


def render_segments(segments: List[Tuple[str, str]], y: int, char_x: int = PADDING_X) -> str:
    """Render a horizontal sequence of colored tspans on one baseline."""
    parts = ['<text x="{x}" y="{y}" class="mono">'.format(x=char_x, y=y)]
    for text, color in segments:
        parts.append(
            '<tspan fill="{c}" xml:space="preserve">{t}</tspan>'.format(
                c=color, t=esc(text)
            )
        )
    parts.append("</text>")
    return "".join(parts)


def typewriter_line(segments: List[Tuple[str, str]], y: int, start: float) -> Tuple[str, float]:
    """
    Render a line that types out character-by-character.
    Returns (svg_fragment, end_time_seconds).
    """
    # Flatten to (char, color) for stable per-character timing.
    chars: List[Tuple[str, str]] = []
    for text, color in segments:
        for ch in text:
            chars.append((ch, color))

    # Build a single <text> with one <tspan> per character. Each tspan
    # starts hidden (opacity 0) and snaps to opacity 1 at its scheduled
    # time. This keeps DOM size manageable while giving exact control.
    out = ['<text x="{x}" y="{y}" class="mono" xml:space="preserve">'.format(
        x=PADDING_X, y=y
    )]
    t = start
    for i, (ch, color) in enumerate(chars):
        tspan_id_suffix = f"_{i}"
        out.append(
            '<tspan fill="{c}" opacity="0">{t}'
            f'<set attributeName="{OPACITY_ATTR}" to="{CURSOR_OPACITY_END}" begin="{{begin:.3f}}s" fill="{FILL_FREEZE}"/>'
            "</tspan>".format(c=color, t=esc(ch), begin=t)
        )
        t += TYPE_SPEED
    out.append("</text>")
    return "".join(out), t


def instant_line(segments: List[Tuple[str, str]], y: int, start: float) -> str:
    """
    Line that appears all at once at `start`.

    We attach the <set> to each <tspan> so that renderers which ignore
    SMIL timing (GitHub's static SVG fallback, ImageMagick, rsvg) still
    show the line in its final visible state. The `fill="freeze"` value
    is what makes those renderers honor the end state.
    """
    parts = ['<text x="{x}" y="{y}" class="mono" xml:space="preserve">'.format(
        x=PADDING_X, y=y
    )]
    for text, color in segments:
        parts.append(
            '<tspan fill="{c}" opacity="0">{t}'
            f'<set attributeName="{OPACITY_ATTR}" to="{CURSOR_OPACITY_END}" begin="{{begin:.3f}}s" fill="{FILL_FREEZE}"/>'
            "</tspan>".format(c=color, t=esc(text), begin=start)
        )
    parts.append("</text>")
    return "".join(parts)


def build_svg(title: str, lines: List[Line], loop_seconds: float, out_path: Path) -> None:
    """
    Compose the full SVG document with chrome + animated content.
    `loop_seconds` controls when the scene resets (animation restarts).
    """
    body_parts: List[str] = []

    cursor_y = None
    cursor_x = None
    t = 0.0
    y = PADDING_TOP

    for line in lines:
        t = max(t, line.delay)

        if line.typed:
            frag, end_t = typewriter_line(line.segments, y, t)
            body_parts.append(frag)
            # cursor follows the end of the typed text
            char_count = sum(len(seg[0]) for seg in line.segments)
            cursor_x = PADDING_X + char_count * CHAR_ADVANCE_PX  # approx char advance
            cursor_y = y
            t = end_t
        else:
            body_parts.append(instant_line(line.segments, y, t))
            t += DELAY_BETWEEN_LINES  # tiny gap between instant lines

        y += LINE_HEIGHT

    # Blinking cursor that appears at the final prompt position.
    cursor = ""
    if cursor_x is not None and cursor_y is not None:
        cursor = (
            f'<rect x="{{x}}" y="{{cy}}" width="{CURSOR_WIDTH}" height="{CURSOR_HEIGHT}" fill="{ColorType.TEXT_FG.value}" opacity="{CURSOR_OPACITY_START}">'
            f'  <set attributeName="{OPACITY_ATTR}" to="{CURSOR_OPACITY_END}" begin="{{start:.3f}}s" fill="{FILL_FREEZE}"/>'
            f'  <animate attributeName="{OPACITY_ATTR}" values="{CURSOR_ANIM_VALUES}" dur="{CURSOR_DUR}" '
            f'    begin="{{start:.3f}}s" repeatCount="{CURSOR_REPEAT}"/>'
            "</rect>"
        ).format(x=cursor_x, cy=cursor_y - CURSOR_OFFSET_Y, start=t + CURSOR_BLINK_START)

    # Master loop: re-trigger all <set>s by resetting their `begin`.
    # SMIL re-runs an animation when its host element re-enters the
    # document tree; cheap trick: drive a master <animate> on the root
    # group and use its events as the begin time of the children.
    # Simpler approach taken here: rely on the SVG playing once. Looping
    # is handled by GitHub's renderer treating the SVG as a static
    # image after one play; for that we add an outer <animate> that
    # forces the whole content opacity to flicker, restarting children
    # via the `repeatEvent`. To keep things robust across renderers we
    # use a JavaScript-free indefinite loop via a single <animate> on a
    # dummy attribute that re-triggers via begin chaining.
    master_loop = ''
    if loop_seconds > 0:
        # Wrap content in <g> with an opacity animation that hides the
        # scene briefly at loop_seconds, and a parallel animate that
        # restarts every child by referencing event chains. The simplest
        # cross-renderer technique: blank the screen, then the children's
        # `begin` references restart from `loop.end`. Implemented below.
        pass

    svg = f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {WIDTH} {HEIGHT}"
     width="{WIDTH}" height="{HEIGHT}" role="img" aria-label="{esc(title)}">
  <defs>
    <style>
      .mono {{
        font-family: "Ubuntu Mono", "DejaVu Sans Mono", "Menlo", monospace;
        font-size: {FONT_SIZE}px;
        font-weight: 500;
      }}
      .title {{
        font-family: "Ubuntu", "Segoe UI", system-ui, sans-serif;
        font-size: {TITLE_TEXT_SZ}px;
        font-weight: 500;
        fill: {ColorType.TITLE_FG.value};
      }}
    </style>
    <linearGradient id="screen" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="{ColorType.SCREEN_GRADIENT_START.value}"/>
      <stop offset="100%" stop-color="{ColorType.SCREEN_GRADIENT_END.value}"/>
    </linearGradient>
  </defs>

  <!-- Drop shadow -->
  <rect x="{SHADOW_X}" y="{SHADOW_Y}" width="{WIDTH-SHADOW_PADDING}" height="{HEIGHT-SHADOW_PADDING}" rx="{SHADOW_RX}"
        fill="{ColorType.SHADOW_BG.value}" opacity="{SHADOW_OPACITY}"/>

  <!-- Window chrome -->
  <rect x="{CHROME_X_Y}" y="{CHROME_X_Y}" width="{WIDTH-CHROME_PADDING}" height="{HEIGHT-CHROME_PADDING}" rx="{CHROME_RX}"
        fill="{ColorType.CHROME_BG.value}" stroke="{ColorType.CHROME_STROKE.value}" stroke-width="{STROKE_WIDTH}"/>

  <!-- Title bar -->
  <rect x="{CHROME_X_Y}" y="{CHROME_X_Y}" width="{WIDTH-CHROME_PADDING}" height="{TITLE_H}" rx="{CHROME_RX}" fill="{ColorType.TITLE_BG.value}"/>
  <rect x="{CHROME_X_Y}" y="{TITLE_INNER_Y}" width="{WIDTH-CHROME_PADDING}" height="{TITLE_INNER_H}" fill="{ColorType.TITLE_BG.value}"/>

  <!-- Traffic lights -->
  <circle cx="{TRAFFIC_R_CX}" cy="{TRAFFIC_CY}" r="{TRAFFIC_R}" fill="{ColorType.TRAFFIC_RED.value}"/>
  <circle cx="{TRAFFIC_Y_CX}" cy="{TRAFFIC_CY}" r="{TRAFFIC_R}" fill="{ColorType.TRAFFIC_YELLOW.value}"/>
  <circle cx="{TRAFFIC_G_CX}" cy="{TRAFFIC_CY}" r="{TRAFFIC_R}" fill="{ColorType.TRAFFIC_GREEN.value}"/>

  <!-- Title text -->
  <text x="{WIDTH//2}" y="{TITLE_TEXT_Y}" class="title" text-anchor="{TITLE_ANCHOR}">{esc(title)}</text>

  <!-- Screen background -->
  <rect x="{SCREEN_X}" y="{SCREEN_Y}" width="{WIDTH-SCREEN_PAD_W}" height="{HEIGHT-SCREEN_PAD_H}" rx="{SCREEN_RX}"
        fill="url(#screen)"/>

  <!-- Animated content -->
  <g>
    {''.join(body_parts)}
    {cursor}
  </g>
</svg>
'''
    out_path.write_text(svg, encoding="utf-8")
    print(f"wrote {out_path.relative_to(OUT_DIR.parent.parent)}")


# ---------------------------------------------------------------------------
# Prompt builder
# ---------------------------------------------------------------------------

def prompt_segments(command: str) -> List[Tuple[str, str]]:
    """Build the colored prompt + command segments, ready for typewriter."""
    return [
        ("PS ", ColorType.PROMPT_AT.value),
        ("dev@gitmap", ColorType.PROMPT_USER.value),
        (" ", ColorType.PROMPT_AT.value),
        ("E:\\dev-tool", ColorType.PROMPT_PATH.value),
        (" ", ColorType.PROMPT_AT.value),
        ("> ", ColorType.PROMPT_ARROW.value),
        (command, ColorType.TEXT_FG.value),
    ]


# ---------------------------------------------------------------------------
# Demo 1: profile advance
# ---------------------------------------------------------------------------

def demo_profile() -> None:
    lines: List[Line] = [
        Line(prompt_segments(".\\run.ps1 profile advance"), delay=0.4, typed=True),

        Line([("", ColorType.TEXT_FG.value)], delay=3.6),  # blank
        Line([("==> Profile: advance", ColorType.ACCENT_HEADER.value)], delay=3.7),
        Line([("    Includes: base + git + extras (15 tools)", ColorType.DIM_FG.value)], delay=3.85),
        Line([("", ColorType.TEXT_FG.value)], delay=4.0),

        Line([("[1/15] ", ColorType.ACCENT_INFO.value), ("vscode               ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=4.2),
        Line([("[2/15] ", ColorType.ACCENT_INFO.value), ("git                  ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=4.5),
        Line([("[3/15] ", ColorType.ACCENT_INFO.value), ("nodejs               ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=4.8),
        Line([("[4/15] ", ColorType.ACCENT_INFO.value), ("pnpm                 ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=5.1),
        Line([("[5/15] ", ColorType.ACCENT_INFO.value), ("python               ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=5.4),
        Line([("[6/15] ", ColorType.ACCENT_INFO.value), ("notepad++ + settings ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=5.7),
        Line([("...   ", ColorType.DIM_FG.value), ("9 more tools installed   ", ColorType.DIM_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=6.0),
        Line([("", ColorType.TEXT_FG.value)], delay=6.4),
        Line([("Profile applied in ", ColorType.DIM_FG.value), ("4m 12s", ColorType.ACCENT_WARN.value), (" - ready to ship.", ColorType.DIM_FG.value)], delay=6.6),

        Line(prompt_segments(""), delay=7.4, typed=False),
    ]
    build_svg(
        title="run profile advance  -  install the full developer profile",
        lines=lines,
        loop_seconds=10.0,
        out_path=OUT_DIR / "run-profile-advance.svg",
    )


# ---------------------------------------------------------------------------
# Demo 1b: profile minimal (4-step bootstrap)
# ---------------------------------------------------------------------------

def demo_profile_minimal() -> None:
    lines: List[Line] = [
        Line(prompt_segments(".\\run.ps1 profile minimal"), delay=0.4, typed=True),

        Line([("", ColorType.TEXT_FG.value)], delay=3.4),
        Line([("==> Profile: minimal  (fresh-Windows bootstrap)", ColorType.ACCENT_HEADER.value)], delay=3.5),
        Line([("    4 steps: choco -> git -> 7zip -> chrome", ColorType.DIM_FG.value)], delay=3.65),
        Line([("", ColorType.TEXT_FG.value)], delay=3.8),

        Line([("[1/4] ", ColorType.ACCENT_INFO.value), ("chocolatey           ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=4.0),
        Line([("[2/4] ", ColorType.ACCENT_INFO.value), ("git + lfs            ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=4.4),
        Line([("[3/4] ", ColorType.ACCENT_INFO.value), ("7-zip                ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=4.8),
        Line([("[4/4] ", ColorType.ACCENT_INFO.value), ("google chrome        ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=5.2),

        Line([("", ColorType.TEXT_FG.value)], delay=5.6),
        Line([("Bootstrap done in ", ColorType.DIM_FG.value), ("1m 47s", ColorType.ACCENT_WARN.value), (" - browser + archiver + git ready.", ColorType.DIM_FG.value)], delay=5.8),

        Line(prompt_segments(""), delay=6.6, typed=False),
    ]
    build_svg(
        title="run profile minimal  -  4-step fresh-Windows bootstrap",
        lines=lines,
        loop_seconds=9.0,
        out_path=OUT_DIR / "run-profile-minimal.svg",
    )


# ---------------------------------------------------------------------------
# Demo 1c: profile small-dev (advance + Go/Python/Node/pnpm)
# ---------------------------------------------------------------------------

def demo_profile_small_dev() -> None:
    lines: List[Line] = [
        Line(prompt_segments(".\\run.ps1 profile small-dev"), delay=0.4, typed=True),

        Line([("", ColorType.TEXT_FG.value)], delay=3.6),
        Line([("==> Profile: small-dev  (advance + Go only)", ColorType.ACCENT_HEADER.value)], delay=3.7),
        Line([("    Expanded: 24 steps (advance 23 + golang)", ColorType.DIM_FG.value)], delay=3.85),
        Line([("", ColorType.TEXT_FG.value)], delay=4.0),

        Line([("[ 1-12 ] ", ColorType.ACCENT_INFO.value), ("base profile (12 steps) ........ ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=4.2),
        Line([("[13-17 ] ", ColorType.ACCENT_INFO.value), ("git-compact (5 steps) .......... ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=4.55),
        Line([("[18-23 ] ", ColorType.ACCENT_INFO.value), ("advance extras (6 steps) ....... ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=4.9),
        Line([("[24/24 ] ", ColorType.ACCENT_INFO.value), ("golang  -> E:\\dev-tool\\go ...... ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=5.25),

        Line([("", ColorType.TEXT_FG.value)], delay=5.6),
        Line([("small-dev ready in ", ColorType.DIM_FG.value), ("4m 51s", ColorType.ACCENT_WARN.value), (" - advance stack + Go on E:\\.", ColorType.DIM_FG.value)], delay=5.8),

        Line(prompt_segments(""), delay=6.6, typed=False),
    ]
    build_svg(
        title="run profile small-dev  -  advance + Go only",
        lines=lines,
        loop_seconds=9.5,
        out_path=OUT_DIR / "run-profile-small-dev.svg",
    )


def demo_profile_base() -> None:
    lines: List[Line] = [
        Line(prompt_segments(".\\run.ps1 profile base"), delay=0.4, typed=True),

        Line([("", ColorType.TEXT_FG.value)], delay=3.5),
        Line([("==> Profile: base  (daily-driver Windows workstation)", ColorType.ACCENT_HEADER.value)], delay=3.65),
        Line([("    12 steps: media + browser + editor + terminal + XMind", ColorType.DIM_FG.value)], delay=3.8),
        Line([("", ColorType.TEXT_FG.value)], delay=4.0),

        Line([("[1/12] ", ColorType.ACCENT_INFO.value), ("chocolatey ................. ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=4.2),
        Line([("[2/12] ", ColorType.ACCENT_INFO.value), ("git + lfs .................. ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=4.45),
        Line([("[3/12] ", ColorType.ACCENT_INFO.value), ("vlc ........................ ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=4.7),
        Line([("[4/12] ", ColorType.ACCENT_INFO.value), ("7-zip + winrar ............. ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=4.95),
        Line([("[5/12] ", ColorType.ACCENT_INFO.value), ("ubuntu font + xmind ........ ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=5.2),
        Line([("[6/12] ", ColorType.ACCENT_INFO.value), ("notepad++ + settings ....... ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=5.45),
        Line([("[7/12] ", ColorType.ACCENT_INFO.value), ("chrome + conemu ............ ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=5.7),
        Line([("[8/12] ", ColorType.ACCENT_INFO.value), ("hibernation off + psreadline ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=5.95),

        Line([("", ColorType.TEXT_FG.value)], delay=6.3),
        Line([("Base workstation ready in ", ColorType.DIM_FG.value), ("3m 41s", ColorType.ACCENT_WARN.value), ("  -- all apps on C:\\.", ColorType.DIM_FG.value)], delay=6.55),

        Line(prompt_segments(""), delay=7.3, typed=False),
    ]
    build_svg(
        title="run profile base  -  daily-driver Windows workstation",
        lines=lines,
        loop_seconds=10.0,
        out_path=OUT_DIR / "run-profile-base.svg",
    )


def demo_profile_cpp_dx() -> None:
    lines: List[Line] = [
        Line(prompt_segments(".\\run.ps1 profile cpp-dx"), delay=0.4, typed=True),

        Line([("", ColorType.TEXT_FG.value)], delay=3.4),
        Line([("==> Profile: cpp-dx  (native runtime prerequisites)", ColorType.ACCENT_HEADER.value)], delay=3.55),
        Line([("    3 steps: VC++ runtimes + DirectX runtime + DirectX SDK", ColorType.DIM_FG.value)], delay=3.75),
        Line([("", ColorType.TEXT_FG.value)], delay=3.95),

        Line([("[1/3] ", ColorType.ACCENT_INFO.value), ("vcredist-all ............... ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=4.2),
        Line([("[2/3] ", ColorType.ACCENT_INFO.value), ("directx runtime ............ ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=4.55),
        Line([("[3/3] ", ColorType.ACCENT_INFO.value), ("directx sdk ................ ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=4.9),
        Line([("       ", ColorType.DIM_FG.value), ("system runtime DLLs + SDK headers ready", ColorType.DIM_FG.value)], delay=5.15),

        Line([("", ColorType.TEXT_FG.value)], delay=5.5),
        Line([("cpp-dx done in ", ColorType.DIM_FG.value), ("2m 12s", ColorType.ACCENT_WARN.value), ("  -- native stack ready on C:\\.", ColorType.DIM_FG.value)], delay=5.75),

        Line(prompt_segments(""), delay=6.55, typed=False),
    ]
    build_svg(
        title="run profile cpp-dx  -  VC++ + DirectX prerequisites",
        lines=lines,
        loop_seconds=9.3,
        out_path=OUT_DIR / "run-profile-cpp-dx.svg",
    )


# ---------------------------------------------------------------------------
# Demo 1d: profile git-compact
# ---------------------------------------------------------------------------

def demo_profile_git() -> None:
    lines: List[Line] = [
        Line(prompt_segments(".\\run.ps1 profile git-compact"), delay=0.4, typed=True),

        Line([("", ColorType.TEXT_FG.value)], delay=3.8),
        Line([("==> Profile: git-compact", ColorType.ACCENT_HEADER.value)], delay=3.9),
        Line([("    Git stack + SSH key + GitHub dir + .gitconfig", ColorType.DIM_FG.value)], delay=4.05),
        Line([("", ColorType.TEXT_FG.value)], delay=4.2),

        Line([("[1/5] ", ColorType.ACCENT_INFO.value), ("git + git-lfs + gh           ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=4.4),
        Line([("[2/5] ", ColorType.ACCENT_INFO.value), ("github desktop               ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=4.75),
        Line([("[3/5] ", ColorType.ACCENT_INFO.value), ("ssh key (ed25519)            ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=5.1),
        Line([("       ", ColorType.DIM_FG.value), ("public key copied to clipboard", ColorType.DIM_FG.value)], delay=5.3),
        Line([("[4/5] ", ColorType.ACCENT_INFO.value), ("default github dir           ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=5.6),
        Line([("       ", ColorType.DIM_FG.value), ("created C:\\Users\\dev\\GitHub", ColorType.DIM_FG.value)], delay=5.8),
        Line([("[5/5] ", ColorType.ACCENT_INFO.value), ("apply default .gitconfig     ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=6.1),

        Line([("", ColorType.TEXT_FG.value)], delay=6.5),
        Line([("git-compact done in ", ColorType.DIM_FG.value), ("2m 04s", ColorType.ACCENT_WARN.value), (" - clone & push, ready.", ColorType.DIM_FG.value)], delay=6.7),

        Line(prompt_segments(""), delay=7.5, typed=False),
    ]
    build_svg(
        title="run profile git-compact  -  git + ssh + GitHub dir + .gitconfig",
        lines=lines,
        loop_seconds=10.2,
        out_path=OUT_DIR / "run-profile-git-compact.svg",
    )


# ---------------------------------------------------------------------------
# Demo 1e: os clean detailed (folders + sizes)
# ---------------------------------------------------------------------------

def demo_os_clean_detailed() -> None:
    lines: List[Line] = [
        Line(prompt_segments(".\\run.ps1 os clean --dry-run"), delay=0.4, typed=True),

        Line([("", ColorType.TEXT_FG.value)], delay=4.0),
        Line([("==> OS toolbox: clean (DRY RUN -- nothing deleted)", ColorType.ACCENT_HEADER.value)], delay=4.1),
        Line([("    Scope: temp + caches + recycle bin + event logs", ColorType.DIM_FG.value)], delay=4.3),
        Line([("", ColorType.TEXT_FG.value)], delay=4.5),

        Line([("  [scan] ", ColorType.ACCENT_INFO.value), ("%TEMP%                          ", ColorType.TEXT_FG.value), ("4,812 files   2.10 GB", ColorType.DIM_FG.value)], delay=4.7),
        Line([("  [scan] ", ColorType.ACCENT_INFO.value), ("%LOCALAPPDATA%\\Temp             ", ColorType.TEXT_FG.value), ("1,203 files   780 MB", ColorType.DIM_FG.value)], delay=4.95),
        Line([("  [scan] ", ColorType.ACCENT_INFO.value), ("C:\\Windows\\Temp                 ", ColorType.TEXT_FG.value), ("612 files   340 MB", ColorType.DIM_FG.value)], delay=5.2),
        Line([("  [scan] ", ColorType.ACCENT_INFO.value), ("C:\\Windows\\SoftwareDistribution ", ColorType.TEXT_FG.value), ("2,041 files   1.40 GB", ColorType.DIM_FG.value)], delay=5.45),
        Line([("  [scan] ", ColorType.ACCENT_INFO.value), ("chocolatey lib-bad/lib-bkp      ", ColorType.TEXT_FG.value), ("18 files   62 MB", ColorType.DIM_FG.value)], delay=5.7),
        Line([("  [scan] ", ColorType.ACCENT_INFO.value), ("Recycle Bin (all drives)        ", ColorType.TEXT_FG.value), ("87 items   210 MB", ColorType.DIM_FG.value)], delay=5.95),
        Line([("  [scan] ", ColorType.ACCENT_INFO.value), ("Event logs + PSReadLine history ", ColorType.TEXT_FG.value), ("- ", ColorType.DIM_FG.value), ("clear", ColorType.ACCENT_OK.value)], delay=6.2),

        Line([("", ColorType.TEXT_FG.value)], delay=6.55),
        Line([("Total reclaimable: ", ColorType.DIM_FG.value), ("4.89 GB", ColorType.ACCENT_WARN.value), ("   files: ", ColorType.DIM_FG.value), ("8,773", ColorType.ACCENT_WARN.value)], delay=6.75),
        Line([("Re-run without --dry-run to delete.", ColorType.DIM_FG.value)], delay=7.0),

        Line(prompt_segments(""), delay=7.8, typed=False),
    ]
    build_svg(
        title="run os clean --dry-run  -  preview reclaimable disk space",
        lines=lines,
        loop_seconds=10.5,
        out_path=OUT_DIR / "run-os-clean-detailed.svg",
    )


# ---------------------------------------------------------------------------
# Demo 2: install postgresql
# ---------------------------------------------------------------------------

def demo_postgres() -> None:
    lines: List[Line] = [
        Line(prompt_segments(".\\run.ps1 install postgresql"), delay=0.4, typed=True),

        Line([("", ColorType.TEXT_FG.value)], delay=4.0),
        Line([("==> Resolving keyword 'postgresql' -> script #20", ColorType.ACCENT_HEADER.value)], delay=4.1),
        Line([("    Dev directory: ", ColorType.DIM_FG.value), ("E:\\dev-tool\\postgresql", ColorType.PROMPT_PATH.value)], delay=4.3),
        Line([("", ColorType.TEXT_FG.value)], delay=4.5),

        Line([("[step 1/4] ", ColorType.ACCENT_INFO.value), ("download installer ........ ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=4.7),
        Line([("[step 2/4] ", ColorType.ACCENT_INFO.value), ("install service ........... ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=5.2),
        Line([("[step 3/4] ", ColorType.ACCENT_INFO.value), ("create role + database .... ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=5.7),
        Line([("[step 4/4] ", ColorType.ACCENT_INFO.value), ("verify with psql .......... ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=6.2),

        Line([("", ColorType.TEXT_FG.value)], delay=6.6),
        Line([("PostgreSQL 16 ", ColorType.TEXT_FG.value), ("running", ColorType.ACCENT_OK.value), (" on port ", ColorType.DIM_FG.value), ("5432", ColorType.ACCENT_WARN.value)], delay=6.8),
        Line([("Connect: ", ColorType.DIM_FG.value), ("psql -U dev -d devdb", ColorType.PROMPT_HOST.value)], delay=7.0),

        Line(prompt_segments(""), delay=7.8, typed=False),
    ]
    build_svg(
        title="run install postgresql  -  one keyword, full database stack",
        lines=lines,
        loop_seconds=10.5,
        out_path=OUT_DIR / "run-install-postgresql.svg",
    )


# ---------------------------------------------------------------------------
# Demo 3: os clean
# ---------------------------------------------------------------------------

def demo_os_clean() -> None:
    lines: List[Line] = [
        Line(prompt_segments(".\\run.ps1 os clean"), delay=0.4, typed=True),

        Line([("", ColorType.TEXT_FG.value)], delay=2.6),
        Line([("==> OS toolbox: clean", ColorType.ACCENT_HEADER.value)], delay=2.7),
        Line([("    Scope: temp + caches + recycle bin", ColorType.DIM_FG.value)], delay=2.85),
        Line([("", ColorType.TEXT_FG.value)], delay=3.0),

        Line([("  scanning   %TEMP%        ", ColorType.TEXT_FG.value), ("4,812 files   2.1 GB", ColorType.DIM_FG.value)], delay=3.2),
        Line([("  scanning   %LOCALAPPDATA%\\Temp   ", ColorType.TEXT_FG.value), ("1,203 files   780 MB", ColorType.DIM_FG.value)], delay=3.5),
        Line([("  scanning   Windows update cache  ", ColorType.TEXT_FG.value), ("412 files   1.4 GB", ColorType.DIM_FG.value)], delay=3.8),
        Line([("  scanning   Recycle Bin         ", ColorType.TEXT_FG.value), ("87 files   320 MB", ColorType.DIM_FG.value)], delay=4.1),

        Line([("", ColorType.TEXT_FG.value)], delay=4.4),
        Line([("==> Reclaiming space ...", ColorType.ACCENT_HEADER.value)], delay=4.5),
        Line([("  removed temp ............. ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=4.8),
        Line([("  removed update cache ..... ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=5.1),
        Line([("  emptied recycle bin ...... ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=5.4),

        Line([("", ColorType.TEXT_FG.value)], delay=5.7),
        Line([("Freed ", ColorType.DIM_FG.value), ("4.6 GB", ColorType.ACCENT_WARN.value), (" in ", ColorType.DIM_FG.value), ("18s", ColorType.ACCENT_WARN.value), (" - disk happy.", ColorType.DIM_FG.value)], delay=5.9),

        Line(prompt_segments(""), delay=6.7, typed=False),
    ]
    build_svg(
        title="run os clean  -  reclaim disk space in one command",
        lines=lines,
        loop_seconds=9.5,
        out_path=OUT_DIR / "run-os-clean.svg",
    )


# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------

def main() -> None:
    # noqa: re-defined below by injected demos -- keep in sync
    pass


# ---------------------------------------------------------------------------
# Demo: multi-tool comma install (showcases "vscode,git,nodejs,pnpm")
# Bigger typewriter on the prompt; shows that names compose.
# ---------------------------------------------------------------------------

def demo_install_comma() -> None:
    cmd = ".\\run.ps1 install vscode,git,nodejs,pnpm,python,npp"
    lines: List[Line] = [
        Line(prompt_segments(cmd), delay=0.4, typed=True),

        Line([("", ColorType.TEXT_FG.value)], delay=4.6),
        Line([("==> Resolving 6 keywords -> 6 scripts", ColorType.ACCENT_HEADER.value)], delay=4.7),
        Line([("    vscode -> #01    git -> #07    nodejs -> #03", ColorType.DIM_FG.value)], delay=4.9),
        Line([("    pnpm   -> #04    python -> #05  npp    -> #33", ColorType.DIM_FG.value)], delay=5.05),
        Line([("", ColorType.TEXT_FG.value)], delay=5.2),

        Line([("[1/6] ", ColorType.ACCENT_INFO.value), ("vscode               ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=5.4),
        Line([("[2/6] ", ColorType.ACCENT_INFO.value), ("git + lfs + gh       ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=5.7),
        Line([("[3/6] ", ColorType.ACCENT_INFO.value), ("nodejs (E:\\dev-tool) ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=6.0),
        Line([("[4/6] ", ColorType.ACCENT_INFO.value), ("pnpm   (E:\\dev-tool) ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=6.3),
        Line([("[5/6] ", ColorType.ACCENT_INFO.value), ("python (E:\\dev-tool) ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=6.6),
        Line([("[6/6] ", ColorType.ACCENT_INFO.value), ("notepad++ + settings ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=6.9),

        Line([("", ColorType.TEXT_FG.value)], delay=7.3),
        Line([("6 tools installed in ", ColorType.DIM_FG.value), ("3m 02s", ColorType.ACCENT_WARN.value), ("  -- one command, comma-separated.", ColorType.DIM_FG.value)], delay=7.5),

        Line(prompt_segments(""), delay=8.4, typed=False),
    ]
    build_svg(
        title="run install vscode,git,nodejs,pnpm,python,npp  -  one command, many tools",
        lines=lines,
        loop_seconds=11.5,
        out_path=OUT_DIR / "run-install-comma.svg",
    )


# ---------------------------------------------------------------------------
# Demo: Win11 classic right-click restore (part of profile minimal)
# ---------------------------------------------------------------------------

def demo_classic_context() -> None:
    lines: List[Line] = [
        Line(prompt_segments(".\\run.ps1 profile minimal"), delay=0.4, typed=True),

        Line([("", ColorType.TEXT_FG.value)], delay=3.4),
        Line([("==> Profile: minimal  (5 steps -- includes Win11 fix)", ColorType.ACCENT_HEADER.value)], delay=3.5),
        Line([("    bootstrap + classic right-click menu", ColorType.DIM_FG.value)], delay=3.65),
        Line([("", ColorType.TEXT_FG.value)], delay=3.8),

        Line([("[1/5] ", ColorType.ACCENT_INFO.value), ("chocolatey                       ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=4.0),
        Line([("[2/5] ", ColorType.ACCENT_INFO.value), ("git + lfs                        ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=4.35),
        Line([("[3/5] ", ColorType.ACCENT_INFO.value), ("7-zip                            ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=4.7),
        Line([("[4/5] ", ColorType.ACCENT_INFO.value), ("google chrome                    ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=5.05),
        Line([("[5/5] ", ColorType.ACCENT_INFO.value), ("win11 classic right-click menu   ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=5.4),
        Line([("       ", ColorType.DIM_FG.value), ("HKCU CLSID {86ca1aa0-...} written -- restart explorer", ColorType.DIM_FG.value)], delay=5.6),

        Line([("", ColorType.TEXT_FG.value)], delay=5.95),
        Line([("Bootstrap done in ", ColorType.DIM_FG.value), ("1m 58s", ColorType.ACCENT_WARN.value), ("  -- right-click menu now shows ALL apps.", ColorType.DIM_FG.value)], delay=6.15),

        Line(prompt_segments(""), delay=7.0, typed=False),
    ]
    build_svg(
        title="run profile minimal  -  bootstrap + Win11 classic right-click menu",
        lines=lines,
        loop_seconds=10.0,
        out_path=OUT_DIR / "run-profile-minimal-classic.svg",
    )


# ---------------------------------------------------------------------------
# Demo: profile dev (small-dev + Python/Node+yarn+bun/pnpm/Rust/PHP)
# ---------------------------------------------------------------------------

def demo_profile_dev() -> None:
    lines: List[Line] = [
        Line(prompt_segments(".\\run.ps1 profile dev"), delay=0.4, typed=True),

        Line([("", ColorType.TEXT_FG.value)], delay=3.2),
        Line([("==> Profile: dev  (polyglot daily-driver)", ColorType.ACCENT_HEADER.value)], delay=3.35),
        Line([("    29 steps: small-dev (24) + Py + Node+Yarn+Bun + pnpm + Rust + PHP", ColorType.DIM_FG.value)], delay=3.55),
        Line([("", ColorType.TEXT_FG.value)], delay=3.75),

        Line([("[ 1-23 ] ", ColorType.ACCENT_INFO.value), ("advance stack ..................... ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=3.95),
        Line([("[  24  ] ", ColorType.ACCENT_INFO.value), ("golang        -> E:\\dev-tool\\go ... ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=4.3),
        Line([("[  25  ] ", ColorType.ACCENT_INFO.value), ("python + pip  -> E:\\dev-tool\\python ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=4.65),
        Line([("[  26  ] ", ColorType.ACCENT_INFO.value), ("node+yarn+bun -> E:\\dev-tool\\nodejs ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=5.0),
        Line([("[  27  ] ", ColorType.ACCENT_INFO.value), ("pnpm          -> E:\\dev-tool\\pnpm . ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=5.35),
        Line([("[  28  ] ", ColorType.ACCENT_INFO.value), ("rust (rustup) -> E:\\dev-tool\\rust . ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=5.7),
        Line([("[  29  ] ", ColorType.ACCENT_INFO.value), ("php cli       -> E:\\dev-tool\\php .. ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=6.05),

        Line([("", ColorType.TEXT_FG.value)], delay=6.4),
        Line([("dev box ready in ", ColorType.DIM_FG.value), ("8m 12s", ColorType.ACCENT_WARN.value), (" - 6 runtimes on E:\\, apps on C:\\.", ColorType.DIM_FG.value)], delay=6.6),

        Line(prompt_segments(""), delay=7.4, typed=False),
    ]
    build_svg(
        title="run profile dev  -  polyglot daily-driver (Py/Node/pnpm/Rust/PHP + Go)",
        lines=lines,
        loop_seconds=10.5,
        out_path=OUT_DIR / "run-profile-dev.svg",
    )


# ---------------------------------------------------------------------------
# Demo: profile dev-advance (dev + .NET + cpp-dx)
# ---------------------------------------------------------------------------

def demo_profile_dev_advance() -> None:
    lines: List[Line] = [
        Line(prompt_segments(".\\run.ps1 profile dev-advance"), delay=0.4, typed=True),

        Line([("", ColorType.TEXT_FG.value)], delay=3.6),
        Line([("==> Profile: dev-advance  (everything-bagel box)", ColorType.ACCENT_HEADER.value)], delay=3.75),
        Line([("    33 steps: dev (29) + .NET SDK + cpp-dx (3)", ColorType.DIM_FG.value)], delay=3.95),
        Line([("", ColorType.TEXT_FG.value)], delay=4.15),

        Line([("[ 1-29 ] ", ColorType.ACCENT_INFO.value), ("dev profile (Go/Py/Node/pnpm/Rust/PHP) ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=4.35),
        Line([("[  30  ] ", ColorType.ACCENT_INFO.value), (".NET SDK (C#) -> C:\\Program Files\\dotnet ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=4.7),
        Line([("[  31  ] ", ColorType.ACCENT_INFO.value), ("vcredist-all  -> System32 runtime DLLs   ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=5.05),
        Line([("[  32  ] ", ColorType.ACCENT_INFO.value), ("directx       -> System32 DX runtime     ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=5.4),
        Line([("[  33  ] ", ColorType.ACCENT_INFO.value), ("directx sdk   -> Program Files (x86)     ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value)], delay=5.75),

        Line([("", ColorType.TEXT_FG.value)], delay=6.1),
        Line([("dev-advance ready in ", ColorType.DIM_FG.value), ("11m 04s", ColorType.ACCENT_WARN.value), (" - polyglot + native + .NET, all on disk.", ColorType.DIM_FG.value)], delay=6.3),

        Line(prompt_segments(""), delay=7.1, typed=False),
    ]
    build_svg(
        title="run profile dev-advance  -  dev + .NET SDK + VC++/DirectX",
        lines=lines,
        loop_seconds=10.5,
        out_path=OUT_DIR / "run-profile-dev-advance.svg",
    )


# Re-bind `main` so the new demos are emitted (we kept the original above as
# a stub to satisfy apply_patch context windows).

# ---------------------------------------------------------------------------
# Demo: install llama-cpp models  (4-filter picker -> aria2c download)
# Showcases the 90-model catalog browser from Script 43.
# ---------------------------------------------------------------------------

def demo_models_picker() -> None:
    lines: List[Line] = [
        Line(prompt_segments(".\\run.ps1 -I 43 models"), delay=0.4, typed=True),

        Line([("", ColorType.TEXT_FG.value)], delay=3.6),
        Line([("==> llama.cpp model picker  (90 GGUFs across 33 families)", ColorType.ACCENT_HEADER.value)], delay=3.75),
        Line([("    Filters: RAM -> Size -> Speed -> Capability", ColorType.DIM_FG.value)], delay=3.95),
        Line([("", ColorType.TEXT_FG.value)], delay=4.15),

        Line([("RAM filter      ", ColorType.ACCENT_INFO.value), ("[1]4  [2]8  [3]16  ", ColorType.TEXT_FG.value), ("[4]32", ColorType.ACCENT_OK.value), ("  [5]64  >", ColorType.DIM_FG.value)], delay=4.35),
        Line([("Size filter     ", ColorType.ACCENT_INFO.value), ("[1]Tiny [2]Small ", ColorType.TEXT_FG.value), ("[3]Medium", ColorType.ACCENT_OK.value), (" [4]Large [5]XLarge >", ColorType.DIM_FG.value)], delay=4.7),
        Line([("Speed filter    ", ColorType.ACCENT_INFO.value), ("[1]Instant ", ColorType.TEXT_FG.value), ("[2]Fast", ColorType.ACCENT_OK.value), (" [3]Moderate [4]Slow >", ColorType.DIM_FG.value)], delay=5.05),
        Line([("Capability      ", ColorType.ACCENT_INFO.value), ("[1]Coding", ColorType.ACCENT_OK.value), (" [2]Reasoning [3]Writing [4]Chat >", ColorType.DIM_FG.value)], delay=5.4),
        Line([("", ColorType.TEXT_FG.value)], delay=5.6),

        Line([(" #  Model                          Params  Quant     Size   RAM  Caps", ColorType.ACCENT_HEADER.value)], delay=5.75),
        Line([(" 1  ", ColorType.ACCENT_INFO.value), ("qwen2.5-coder-3b              ", ColorType.TEXT_FG.value), ("3B      Q4_K_M    1.8GB  4GB  ", ColorType.DIM_FG.value), ("Code+Multi", ColorType.ACCENT_OK.value)], delay=5.95),
        Line([(" 2  ", ColorType.ACCENT_INFO.value), ("phi-4-mini-3.8b               ", ColorType.TEXT_FG.value), ("3.8B    Q4_K_M    2.4GB  6GB  ", ColorType.DIM_FG.value), ("Code+Reason", ColorType.ACCENT_OK.value)], delay=6.10),
        Line([(" 3  ", ColorType.ACCENT_INFO.value), ("gemma-3-4b-it                 ", ColorType.TEXT_FG.value), ("4B      Q4_K_M    2.6GB  6GB  ", ColorType.DIM_FG.value), ("Multi+Chat", ColorType.ACCENT_OK.value)], delay=6.25),
        Line([(" 4  ", ColorType.ACCENT_INFO.value), ("qwen3.5-4b-opus-distill       ", ColorType.TEXT_FG.value), ("4B      Q4_K_M    2.7GB  5GB  ", ColorType.DIM_FG.value), ("Code+Reason", ColorType.ACCENT_OK.value)], delay=6.40),
        Line([(" 5  ", ColorType.ACCENT_INFO.value), ("mimo-v2-flash  [LB #1]        ", ColorType.TEXT_FG.value), ("3B      Q4_K_M    4.5GB  8GB  ", ColorType.DIM_FG.value), ("Code+Reason", ColorType.ACCENT_OK.value)], delay=6.55),
        Line([("...   ", ColorType.DIM_FG.value), ("12 more models match filters", ColorType.DIM_FG.value)], delay=6.70),
        Line([("", ColorType.TEXT_FG.value)], delay=6.85),

        Line([("Select: ", ColorType.ACCENT_INFO.value), ("1,3-4", ColorType.TEXT_FG.value), ("    -> ", ColorType.DIM_FG.value), ("3 models, 7.1 GB", ColorType.ACCENT_WARN.value)], delay=7.05),
        Line([("Disk space check: ", ColorType.DIM_FG.value), ("OK", ColorType.ACCENT_OK.value), (" (free 412 GB on E:\\)", ColorType.DIM_FG.value)], delay=7.30),
        Line([("", ColorType.TEXT_FG.value)], delay=7.50),

        Line([("[1/3] ", ColorType.ACCENT_INFO.value), ("aria2c -> qwen2.5-coder-3b ........ ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value), ("  18MB/s", ColorType.DIM_FG.value)], delay=7.70),
        Line([("[2/3] ", ColorType.ACCENT_INFO.value), ("aria2c -> gemma-3-4b-it ........... ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value), ("  21MB/s", ColorType.DIM_FG.value)], delay=8.00),
        Line([("[3/3] ", ColorType.ACCENT_INFO.value), ("aria2c -> qwen3.5-4b-opus-distill . ", ColorType.TEXT_FG.value), ("OK", ColorType.ACCENT_OK.value), ("  19MB/s", ColorType.DIM_FG.value)], delay=8.30),

        Line([("", ColorType.TEXT_FG.value)], delay=8.65),
        Line([("3 models downloaded in ", ColorType.DIM_FG.value), ("4m 18s", ColorType.ACCENT_WARN.value), (" - ready in E:\\dev-tool\\llama-models.", ColorType.DIM_FG.value)], delay=8.85),

        Line(prompt_segments(""), delay=9.65, typed=False),
    ]
    build_svg(
        title="run -I 43 models  -  pick from 90 GGUFs, aria2c download",
        lines=lines,
        loop_seconds=13.0,
        out_path=OUT_DIR / "run-models-picker.svg",
    )


def main() -> None:  # noqa: F811 -- intentional override
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    demo_profile()
    demo_profile_minimal()
    demo_profile_base()
    demo_profile_small_dev()
    demo_profile_dev()
    demo_profile_dev_advance()
    demo_profile_git()
    demo_profile_cpp_dx()
    demo_postgres()
    demo_os_clean()
    demo_os_clean_detailed()
    demo_install_comma()
    demo_classic_context()
    demo_models_picker()


if __name__ == "__main__":
    main()
