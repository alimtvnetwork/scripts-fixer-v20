"""WordPress REST API client managing pages, preflight backups, and rollback."""
from __future__ import annotations

import base64
import json
import urllib.request
from datetime import datetime
from pathlib import Path
from typing import Any

from scripts.app_errors import AppError, Result
from scripts.core_constants import EncodingConstants


class WpRestClient:
    def __init__(self, site_url: str, username: str, password: str) -> None:
        self.site_url = site_url.rstrip("/")
        self.auth_token = base64.b64encode(f"{username}:{password}".encode(EncodingConstants.UTF8)).decode(EncodingConstants.ASCII)

    def _headers(self) -> dict[str, str]:
        return {
            "Authorization": f"Basic {self.auth_token}",
            "Content-Type": "application/json",
            "Accept": "application/json",
        }

    def get_page(self, page_id: int) -> Result[dict[str, Any]]:
        url = f"{self.site_url}/wp-json/wp/v2/pages/{page_id}?context=edit"
        req = urllib.request.Request(url, headers=self._headers())
        try:
            with urllib.request.urlopen(req, timeout=30) as resp:
                return Result.ok(json.loads(resp.read().decode(EncodingConstants.UTF8)))
        except Exception as e:
            return Result.fail(AppError("PAGE_FETCH_ERROR", str(e)))

    def create_preflight_backup(self, page_id: int, registry_path: Path) -> Result[int]:
        fetch_res = self.get_page(page_id)
        if fetch_res.is_failure:
            return Result.fail(fetch_res.error)

        page = fetch_res.value
        title = page.get("title", {}).get("raw", "Untitled")
        meta = page.get("meta", {})
        backup_title = f"{title} - Backup [{datetime.utcnow().strftime('%Y-%m-%d %H:%M:%S')}]"

        payload = {
            "title": backup_title,
            "status": "draft",
            "content": page.get("content", {}).get("raw", ""),
            "meta": meta,
        }
        create_res = self._post_json(f"{self.site_url}/wp-json/wp/v2/pages", payload)
        if create_res.is_failure:
            return Result.fail(create_res.error)

        backup_id = create_res.value.get("id")
        self._record_backup(registry_path, page_id, backup_id, title)
        return Result.ok(backup_id)

    def update_page_ast(self, page_id: int, ast_json_str: str) -> Result[bool]:
        payload = {
            "meta": {
                "_elementor_data": ast_json_str,
                "_elementor_edit_mode": "builder",
            }
        }
        res = self._post_json(f"{self.site_url}/wp-json/wp/v2/pages/{page_id}", payload)
        if res.is_failure:
            return Result.fail(res.error)

        return Result.ok(True)

    def restore_backup(self, page_id: int, backup_id: int) -> Result[bool]:
        backup_res = self.get_page(backup_id)
        if backup_res.is_failure:
            return Result.fail(backup_res.error)

        meta = backup_res.value.get("meta", {})
        payload = {"meta": meta}
        res = self._post_json(f"{self.site_url}/wp-json/wp/v2/pages/{page_id}", payload)
        if res.is_failure:
            return Result.fail(res.error)

        return Result.ok(True)

    def _post_json(self, url: str, data: dict[str, Any]) -> Result[dict[str, Any]]:
        raw = json.dumps(data).encode(EncodingConstants.UTF8)
        req = urllib.request.Request(url, data=raw, headers=self._headers(), method="POST")
        try:
            with urllib.request.urlopen(req, timeout=30) as resp:
                return Result.ok(json.loads(resp.read().decode(EncodingConstants.UTF8)))
        except Exception as e:
            return Result.fail(AppError("REST_POST_ERROR", str(e)))

    def _record_backup(self, registry_path: Path, page_id: int, backup_id: int, title: str) -> None:
        records = []
        if registry_path.exists():
            try:
                with open(registry_path, "r", encoding=EncodingConstants.UTF8) as f:
                    records = json.load(f)
            except Exception:
                pass
        records.append({
            "original_id": page_id,
            "backup_id": backup_id,
            "title": title,
            "timestamp": datetime.utcnow().isoformat() + "Z",
        })
        with open(registry_path, "w", encoding=EncodingConstants.UTF8) as f:
            json.dump(records, f, indent=2)
