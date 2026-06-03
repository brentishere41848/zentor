#!/usr/bin/env python
"""Sign an Avorax .aup manifest with the development Ed25519 key.

This helper is intentionally for dev-channel packages. Production releases should
provide AVORAX_UPDATE_SIGNER and AVORAX_UPDATE_SIGNING_PRIVATE_KEY_HEX from a
protected signing environment instead of using the all-zero development seed.
"""
from __future__ import annotations

import os
import sys
from pathlib import Path

from cryptography.hazmat.primitives.asymmetric.ed25519 import Ed25519PrivateKey

DEV_PRIVATE_KEY_HEX = "0" * 64


def main() -> int:
    if len(sys.argv) != 3:
        print(
            "usage: avorax-dev-sign-manifest.py <manifest.json> <manifest.sig>",
            file=sys.stderr,
        )
        return 2

    manifest_path = Path(sys.argv[1])
    signature_path = Path(sys.argv[2])
    private_key_hex = os.environ.get(
        "AVORAX_UPDATE_SIGNING_PRIVATE_KEY_HEX",
        DEV_PRIVATE_KEY_HEX,
    ).strip()
    key_bytes = bytes.fromhex(private_key_hex)
    if len(key_bytes) not in (32, 64):
        raise ValueError("Ed25519 private key must be a 32-byte seed or 64-byte expanded key")

    signing_key = Ed25519PrivateKey.from_private_bytes(key_bytes[:32])
    signature = signing_key.sign(manifest_path.read_bytes())
    signature_path.parent.mkdir(parents=True, exist_ok=True)
    signature_path.write_text(signature.hex(), encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
