#!/usr/bin/env python3
"""Tests for prepare_release.py (run: python3 -m unittest .github/scripts/test_prepare_release.py)."""

from __future__ import annotations

import datetime as dt
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock

import prepare_release as pr

CHANGELOG = """# Changelog

## [Unreleased]

### Added

- New feature

### Changed

- Tweaked copy

### Fixed

- Dark mascot plate

## [0.2.0] - 2026-08-18

### Added

- Dark mode

[Unreleased]: https://github.com/arioch1984/tasko/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/arioch1984/tasko/releases/tag/v0.2.0
"""

EMPTY = """# Changelog

## [Unreleased]

## [0.2.0] - 2026-08-18

### Added

- Dark mode
"""

PUBSPEC = "name: tasko\nversion: 0.2.0+4\n"
CONSTANTS = """abstract final class AppConstants {
  static const String version = '0.2.0';
  static const int buildNumber = 4;
}
"""


class PrepareReleaseTest(unittest.TestCase):
    def test_added_bumps_minor_and_build(self) -> None:
        unreleased = pr.parse_unreleased(CHANGELOG)
        self.assertTrue(unreleased.has_items())
        self.assertEqual(unreleased.bump_kind(), "minor")
        nxt = pr.parse_pubspec_version("version: 0.2.0+4\n").bump("minor")
        self.assertEqual(nxt.name, "0.3.0")
        self.assertEqual(nxt.full, "0.3.0+5")

    def test_fixes_only_bumps_patch(self) -> None:
        text = CHANGELOG.replace("### Added\n\n- New feature\n\n", "")
        unreleased = pr.parse_unreleased(text)
        self.assertEqual(unreleased.bump_kind(), "patch")

    def test_empty_unreleased_skips(self) -> None:
        self.assertFalse(pr.parse_unreleased(EMPTY).has_items())

    def test_writes_files(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / "lib/core").mkdir(parents=True)
            (root / "CHANGELOG.md").write_text(CHANGELOG, encoding="utf-8")
            (root / "pubspec.yaml").write_text(PUBSPEC, encoding="utf-8")
            (root / "lib/core/constants.dart").write_text(
                CONSTANTS, encoding="utf-8"
            )
            result = pr.prepare(
                root,
                PUBSPEC,
                dt.date(2026, 8, 18),
            )
            self.assertEqual(result["skip"], "false")
            self.assertEqual(result["version"], "0.3.0")
            self.assertEqual(result["branch"], "release/v0.3.0")
            pubspec = (root / "pubspec.yaml").read_text(encoding="utf-8")
            self.assertIn("version: 0.3.0+5", pubspec)
            constants = (root / "lib/core/constants.dart").read_text(
                encoding="utf-8"
            )
            self.assertIn("version = '0.3.0'", constants)
            self.assertIn("buildNumber = 5", constants)
            changelog = (root / "CHANGELOG.md").read_text(encoding="utf-8")
            self.assertIn("## [0.3.0] - 2026-08-18", changelog)
            self.assertIn("- New feature", changelog)
            self.assertIn(
                "[Unreleased]: https://github.com/arioch1984/tasko/compare/v0.3.0...HEAD",
                changelog,
            )
            self.assertIn(
                "[0.3.0]: https://github.com/arioch1984/tasko/releases/tag/v0.3.0",
                changelog,
            )
            self.assertIn("## [Unreleased]", changelog)
            unreleased_now = pr.parse_unreleased(changelog)
            self.assertFalse(unreleased_now.has_items())

    def test_cli_writes_body_file(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / "lib/core").mkdir(parents=True)
            (root / "CHANGELOG.md").write_text(CHANGELOG, encoding="utf-8")
            (root / "pubspec.yaml").write_text(PUBSPEC, encoding="utf-8")
            (root / "lib/core/constants.dart").write_text(
                CONSTANTS, encoding="utf-8"
            )
            body_file = root / "pr-body.md"
            argv = [
                "prepare_release.py",
                "--root",
                str(root),
                "--base-pubspec",
                PUBSPEC,
                "--body-file",
                str(body_file),
                "--today",
                "2026-08-18",
            ]
            with mock.patch.object(sys, "argv", argv):
                pr.main()
            text = body_file.read_text(encoding="utf-8")
            self.assertIn("publishes **v0.3.0**", text)
            self.assertIn("tasko-0.3.0.apk", text)
            self.assertIn("tasko-0.3.0-macos.zip", text)

    def test_skip_when_nothing_to_ship(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            (root / "lib/core").mkdir(parents=True)
            (root / "CHANGELOG.md").write_text(EMPTY, encoding="utf-8")
            (root / "pubspec.yaml").write_text(PUBSPEC, encoding="utf-8")
            (root / "lib/core/constants.dart").write_text(
                CONSTANTS, encoding="utf-8"
            )
            result = pr.prepare(root, PUBSPEC, dt.date(2026, 8, 18))
            self.assertEqual(result["skip"], "true")
            self.assertIn("version: 0.2.0+4", (root / "pubspec.yaml").read_text())


if __name__ == "__main__":
    unittest.main()
