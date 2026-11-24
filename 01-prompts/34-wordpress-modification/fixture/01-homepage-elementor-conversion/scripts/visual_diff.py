"""scripts/visual_diff.py — Headless browser screenshot capture and pixel diffing."""

from pathlib import Path
from PIL import Image, ImageChops
import subprocess


def capture_screenshot_headless(url: str, output_png: Path) -> bool:
    cmd = ["chrome.exe", "--headless", "--disable-gpu", "--window-size=1920,1080", f"--screenshot={output_png}", url]
    try:
        res = subprocess.run(cmd, capture_output=True, timeout=30)
        return res.returncode == 0 and output_png.exists()
    except (subprocess.SubprocessError, FileNotFoundError):
        return False


def compute_visual_diff(img_a_path: Path, img_b_path: Path, diff_output_path: Path) -> float:
    if not img_a_path.exists() or not img_b_path.exists():
        return 100.0
    im_a = Image.open(img_a_path).convert("RGB")
    im_b = Image.open(img_b_path).convert("RGB").resize(im_a.size)
    diff = ImageChops.difference(im_a, im_b)
    diff.save(diff_output_path)
    stat = sum(diff.convert("L").getdata())
    max_stat = 255 * im_a.size[0] * im_a.size[1]
    divergence_percent = round((stat / max_stat) * 100, 2)
    return divergence_percent
