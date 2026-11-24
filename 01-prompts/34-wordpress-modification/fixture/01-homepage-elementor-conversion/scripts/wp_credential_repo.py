"""scripts/wp_credential_repo.py — SQLite credential repository in system temp directory."""

from __future__ import annotations

import os
import sqlite3
import tempfile
from contextlib import contextmanager
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Iterator, Protocol


@dataclass(frozen=True)
class WpCredentialRecord:
    """Immutable credential entity stored in temp SQLite database."""

    site_url: str
    username: str
    password_type: str
    encrypted_secret: str
    encryption_algo: str
    rsa_key_fingerprint: str
    is_active: bool = True
    has_app_password: bool = True
    created_at: str = ""
    updated_at: str = ""


class IWpCredentialRepository(Protocol):
    """Protocol interface isolating all WordPress credential database operations."""

    def save_credential(self, record: WpCredentialRecord) -> bool: ...
    def get_credential(self, site_url: str, username: str) -> WpCredentialRecord | None: ...
    def delete_credential(self, site_url: str, username: str) -> bool: ...
    def list_credentials(self) -> list[WpCredentialRecord]: ...


class SqliteWpCredentialRepository:
    """SQLite implementation of IWpCredentialRepository located in system temp directory."""

    def __init__(self, db_path: Path | str | None = None) -> None:
        if db_path is None:
            self._db_path = Path(tempfile.gettempdir()) / "gitmap" / "wp_credentials.db"
        else:
            self._db_path = Path(db_path)
        self._ensure_db_dir()
        self._init_db()

    def _ensure_db_dir(self) -> None:
        """Ensure parent directory of temp SQLite database exists."""
        if not self._db_path.parent.exists():
            self._db_path.parent.mkdir(parents=True, exist_ok=True)

    @contextmanager
    def _open_conn(self) -> Iterator[sqlite3.Connection]:
        """Open SQLite connection with busy timeout pragma and ensure closure."""
        conn = sqlite3.connect(str(self._db_path), timeout=5.0)
        conn.row_factory = sqlite3.Row
        conn.execute("PRAGMA busy_timeout = 5000;")
        try:
            yield conn
            conn.commit()
        finally:
            conn.close()

    def _init_db(self) -> None:
        """Create PascalCase WpCredentials table with camelCase columns."""
        sql = """
        CREATE TABLE IF NOT EXISTS WpCredentials (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            siteUrl TEXT NOT NULL,
            username TEXT NOT NULL,
            passwordType TEXT NOT NULL,
            encryptedSecret TEXT NOT NULL,
            encryptionAlgo TEXT NOT NULL,
            rsaKeyFingerprint TEXT NOT NULL,
            isActive INTEGER NOT NULL DEFAULT 1,
            hasAppPassword INTEGER NOT NULL DEFAULT 1,
            createdAt TEXT NOT NULL,
            updatedAt TEXT NOT NULL
        );
        CREATE UNIQUE INDEX IF NOT EXISTS idx_wp_cred_site_user ON WpCredentials(siteUrl, username);
        """
        with self._open_conn() as conn:
            conn.executescript(sql)

    def save_credential(self, record: WpCredentialRecord) -> bool:
        """Insert or replace WordPress credential record."""
        now = datetime.utcnow().isoformat() + "Z"
        sql = """
        INSERT INTO WpCredentials (
            siteUrl, username, passwordType, encryptedSecret, encryptionAlgo,
            rsaKeyFingerprint, isActive, hasAppPassword, createdAt, updatedAt
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ON CONFLICT(siteUrl, username) DO UPDATE SET
            passwordType = excluded.passwordType,
            encryptedSecret = excluded.encryptedSecret,
            encryptionAlgo = excluded.encryptionAlgo,
            rsaKeyFingerprint = excluded.rsaKeyFingerprint,
            isActive = excluded.isActive,
            hasAppPassword = excluded.hasAppPassword,
            updatedAt = excluded.updatedAt;
        """
        params = (
            record.site_url, record.username, record.password_type,
            record.encrypted_secret, record.encryption_algo, record.rsa_key_fingerprint,
            1 if record.is_active else 0,
            1 if record.has_app_password else 0,
            record.created_at or now, now,
        )
        with self._open_conn() as conn:
            conn.execute(sql, params)
        return True

    def get_credential(self, site_url: str, username: str) -> WpCredentialRecord | None:
        """Retrieve credential by site URL and username."""
        sql = "SELECT * FROM WpCredentials WHERE siteUrl = ? AND username = ? AND isActive = 1;"
        with self._open_conn() as conn:
            row = conn.execute(sql, (site_url, username)).fetchone()
        if row is None:
            return None
        return self._row_to_record(row)

    def delete_credential(self, site_url: str, username: str) -> bool:
        """Delete credential by site URL and username."""
        sql = "DELETE FROM WpCredentials WHERE siteUrl = ? AND username = ?;"
        with self._open_conn() as conn:
            conn.execute(sql, (site_url, username))
        return True

    def list_credentials(self) -> list[WpCredentialRecord]:
        """List all active credentials."""
        sql = "SELECT * FROM WpCredentials WHERE isActive = 1 ORDER BY id DESC;"
        with self._open_conn() as conn:
            rows = conn.execute(sql).fetchall()
        return [self._row_to_record(row) for row in rows]

    def _row_to_record(self, row: sqlite3.Row) -> WpCredentialRecord:
        """Map SQLite row to immutable WpCredentialRecord."""
        return WpCredentialRecord(
            site_url=row["siteUrl"],
            username=row["username"],
            password_type=row["passwordType"],
            encrypted_secret=row["encryptedSecret"],
            encryption_algo=row["encryptionAlgo"],
            rsa_key_fingerprint=row["rsaKeyFingerprint"],
            is_active=bool(row["isActive"]),
            has_app_password=bool(row["hasAppPassword"]),
            created_at=row["createdAt"],
            updated_at=row["updatedAt"],
        )
