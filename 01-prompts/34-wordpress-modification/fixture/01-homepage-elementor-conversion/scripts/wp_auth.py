"""Connection probe and authentication dispatcher."""
from __future__ import annotations

import base64
import json
import urllib.request
from typing import Any

from scripts.app_errors import AppError, Result
from scripts.core_constants import EncodingConstants


def probe_wp_connection(site_url: str, username: str, password: str) -> Result[dict[str, Any]]:
    """Probe WordPress REST API endpoint to assert credentials and roles."""
    url = f"{site_url.rstrip('/')}/wp-json/wp/v2/users/me"
    auth_header = "Basic " + base64.b64encode(f"{username}:{password}".encode(EncodingConstants.UTF8)).decode(EncodingConstants.ASCII)
    req = urllib.request.Request(url, headers={"Authorization": auth_header, "Accept": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=15) as resp:
            data = json.loads(resp.read().decode(EncodingConstants.UTF8))
            return Result.ok(data)
    except Exception as err:
        return Result.fail(AppError("AUTH_FAILURE", f"Connection probe failed: {err}"))
