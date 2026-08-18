#!/usr/bin/env python3
"""Write GitHub Release notes from CHANGELOG.md for a version (e.g. 0.1.2)."""

from __future__ import annotations

import re
import sys
from pathlib import Path


def changelog_body(changelog: str, version: str) -> str:
    pattern = rf"^## \[{re.escape(version)}\][^\n]*\n(.*?)(?=^## \[|\Z)"
    match = re.search(pattern, changelog, flags=re.M | re.S)
    if not match:
        raise SystemExit(f"No CHANGELOG section for [{version}]")
    return match.group(1).strip()


def render_notes(body: str) -> str:
    return (
        f"{body}\n\n"
        "Install the APK from this release. If a previous Tasko build was signed "
        "with the debug keystore, uninstall it first — Android will not update "
        "across signing keys.\n"
    )


def main() -> None:
    if len(sys.argv) != 3:
        raise SystemExit("usage: release_notes.py VERSION OUT_FILE")
    version, out = sys.argv[1], sys.argv[2]
    text = Path("CHANGELOG.md").read_text(encoding="utf-8")
    Path(out).write_text(render_notes(changelog_body(text, version)), encoding="utf-8")


if __name__ == "__main__":
    main()
