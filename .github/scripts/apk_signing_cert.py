#!/usr/bin/env python3
"""Print APK Signature Scheme v2/v3 certificate subject and SHA-1; fail if unsigned or debug-signed."""

from __future__ import annotations

import struct
import subprocess
import sys
import tempfile
from pathlib import Path

MAGIC = b"APK Sig Block 42"
V2_ID = 0x7109871A
V3_ID = 0xF05368C0


def _u32(data: bytes, offset: int) -> int:
    return struct.unpack_from("<I", data, offset)[0]


def _u64(data: bytes, offset: int) -> int:
    return struct.unpack_from("<Q", data, offset)[0]


def _eocd_offset(data: bytes) -> int:
    for i in range(len(data) - 22, max(len(data) - 22 - 65535, 0) - 1, -1):
        if data[i : i + 4] == b"PK\x05\x06":
            return i
    raise SystemExit("APK EOCD not found")


def _signing_pairs(data: bytes) -> list[tuple[int, bytes]]:
    eocd = _eocd_offset(data)
    cd_off = struct.unpack_from("<I", data, eocd + 16)[0]
    if data[cd_off - 16 : cd_off] != MAGIC:
        raise SystemExit("APK has no v2/v3 signing block (unsigned or v1-only)")
    block_size = _u64(data, cd_off - 24)
    block_start = cd_off - 8 - block_size
    if _u64(data, block_start) != block_size:
        raise SystemExit("APK signing block size mismatch")
    pos = block_start + 8
    end = cd_off - 24
    pairs: list[tuple[int, bytes]] = []
    while pos < end:
        pair_len = _u64(data, pos)
        pos += 8
        pair_id = _u32(data, pos)
        pairs.append((pair_id, data[pos + 4 : pos + pair_len]))
        pos += pair_len
    return pairs


def _certs_from_signers(value: bytes) -> list[bytes]:
    certs: list[bytes] = []
    off = 0
    seq_len = _u32(value, off)
    off += 4
    seq_end = off + seq_len
    while off < seq_end:
        slen = _u32(value, off)
        off += 4
        signer = value[off : off + slen]
        off += slen
        signed_len = _u32(signer, 0)
        signed = signer[4 : 4 + signed_len]
        d_off = 0
        digests_len = _u32(signed, d_off)
        d_off += 4 + digests_len
        certs_len = _u32(signed, d_off)
        d_off += 4
        certs_end = d_off + certs_len
        while d_off < certs_end:
            clen = _u32(signed, d_off)
            d_off += 4
            certs.append(signed[d_off : d_off + clen])
            d_off += clen
    return certs


def _openssl_text(der: bytes) -> str:
    with tempfile.NamedTemporaryFile(suffix=".der") as handle:
        handle.write(der)
        handle.flush()
        return subprocess.check_output(
            [
                "openssl",
                "x509",
                "-inform",
                "der",
                "-in",
                handle.name,
                "-noout",
                "-subject",
                "-issuer",
                "-fingerprint",
                "-sha1",
                "-dates",
            ],
            text=True,
        )


def main() -> None:
    if len(sys.argv) != 2:
        raise SystemExit("usage: apk_signing_cert.py APK")
    data = Path(sys.argv[1]).read_bytes()
    certs: list[bytes] = []
    for pair_id, value in _signing_pairs(data):
        if pair_id in (V2_ID, V3_ID):
            certs.extend(_certs_from_signers(value))
    if not certs:
        raise SystemExit("No v2/v3 certificates found")
    texts = [_openssl_text(cert) for cert in certs]
    print("".join(texts), end="")
    blob = "\n".join(texts)
    if "CN=Android Debug" in blob or "CN = Android Debug" in blob:
        raise SystemExit("APK is signed with the debug keystore")


if __name__ == "__main__":
    main()
