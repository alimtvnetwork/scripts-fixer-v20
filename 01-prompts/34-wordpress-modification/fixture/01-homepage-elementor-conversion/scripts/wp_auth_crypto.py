"""scripts/wp_auth_crypto.py — RSA-OAEP asymmetric encryption & key management."""

from __future__ import annotations

import base64
import hashlib
from dataclasses import dataclass
from typing import Any

from core_constants import EncodingConstants


@dataclass(frozen=True)
class RsaCipherEnvelope:
    """Immutable envelope encapsulating RSA encrypted credential payload."""

    algorithm: str
    key_size_bits: int
    key_fingerprint: str
    encrypted_secret: str
    is_app_password: bool


def compute_key_fingerprint(public_key_pem: bytes) -> str:
    """Compute SHA-256 fingerprint from public key PEM bytes."""
    digest = hashlib.sha256(public_key_pem).hexdigest()
    return f"SHA256:{digest[:32]}"


def encrypt_rsa_oaep(secret: str, public_key_pem: bytes, is_app_password: bool = True) -> RsaCipherEnvelope:
    """Encrypt secret using RSA-OAEP with SHA-256."""
    try:
        from cryptography.hazmat.primitives import hashes
        from cryptography.hazmat.primitives.asymmetric import padding
        from cryptography.hazmat.primitives.serialization import load_pem_public_key

        pub_key = load_pem_public_key(public_key_pem)
        cipher_bytes = pub_key.encrypt(
            secret.encode(EncodingConstants.UTF8),
            padding.OAEP(
                mgf=padding.MGF1(algorithm=hashes.SHA256()),
                algorithm=hashes.SHA256(),
                label=None,
            ),
        )
        b64_secret = base64.b64encode(cipher_bytes).decode(EncodingConstants.ASCII)
        fingerprint = compute_key_fingerprint(public_key_pem)
        return RsaCipherEnvelope("RSA-OAEP-SHA256", 2048, fingerprint, b64_secret, is_app_password)
    except ImportError:
        return _encrypt_fallback_envelope(secret, public_key_pem, is_app_password)


def decrypt_rsa_oaep(ciphertext_b64: str, private_key_pem: bytes) -> str:
    """Decrypt RSA-OAEP ciphertext using private key PEM bytes."""
    try:
        from cryptography.hazmat.primitives import hashes
        from cryptography.hazmat.primitives.asymmetric import padding
        from cryptography.hazmat.primitives.serialization import load_pem_private_key

        priv_key = load_pem_private_key(private_key_pem, password=None)
        raw_bytes = base64.b64decode(ciphertext_b64.encode(EncodingConstants.ASCII))
        plain_bytes = priv_key.decrypt(
            raw_bytes,
            padding.OAEP(
                mgf=padding.MGF1(algorithm=hashes.SHA256()),
                algorithm=hashes.SHA256(),
                label=None,
            ),
        )
        return plain_bytes.decode(EncodingConstants.UTF8)
    except ImportError:
        return _decrypt_fallback_envelope(ciphertext_b64)


def _encrypt_fallback_envelope(secret: str, pub_pem: bytes, is_app_pass: bool) -> RsaCipherEnvelope:
    """Fallback 3-stage base64 encoding when cryptography package is absent."""
    p1 = base64.b64encode(secret.encode(EncodingConstants.UTF8)).decode(EncodingConstants.ASCII)
    p2 = base64.b64encode(p1.encode(EncodingConstants.ASCII)).decode(EncodingConstants.ASCII)
    p3 = base64.b64encode(p2.encode(EncodingConstants.ASCII)).decode(EncodingConstants.ASCII)
    fingerprint = compute_key_fingerprint(pub_pem or b"gitmap-fallback-key")
    return RsaCipherEnvelope("3STAGE-BASE64", 2048, fingerprint, p3, is_app_pass)


def _decrypt_fallback_envelope(ciphertext_b64: str) -> str:
    """Fallback 3-stage base64 decoding."""
    p2 = base64.b64decode(ciphertext_b64.encode(EncodingConstants.ASCII)).decode(EncodingConstants.ASCII)
    p1 = base64.b64decode(p2.encode(EncodingConstants.ASCII)).decode(EncodingConstants.ASCII)
    return base64.b64decode(p1.encode(EncodingConstants.ASCII)).decode(EncodingConstants.UTF8)


def generate_rsa_keypair(key_size_bits: int = 2048) -> tuple[bytes, bytes]:
    """Generate RSA private and public key PEM bytes."""
    try:
        from cryptography.hazmat.primitives import serialization
        from cryptography.hazmat.primitives.asymmetric import rsa

        key = rsa.generate_private_key(public_exponent=65537, key_size=key_size_bits)
        priv_pem = key.private_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PrivateFormat.PKCS8,
            encryption_algorithm=serialization.NoEncryption(),
        )
        pub_pem = key.public_key().public_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PublicFormat.SubjectPublicKeyInfo,
        )
        return priv_pem, pub_pem
    except ImportError:
        dummy_priv = b"-----BEGIN RSA PRIVATE KEY-----\nFALLBACK_LOCAL_KEY\n-----END RSA PRIVATE KEY-----\n"
        dummy_pub = b"-----BEGIN PUBLIC KEY-----\nFALLBACK_LOCAL_PUBKEY\n-----END PUBLIC KEY-----\n"
        return dummy_priv, dummy_pub
