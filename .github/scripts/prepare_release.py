#!/usr/bin/env python3
"""Turn [Unreleased] changelog items into a versioned release on disk.

Compares this tree to main's version. Empty Unreleased → skip.
Added items bump minor; otherwise patch. Build number always +1 vs main.
"""

from __future__ import annotations

import argparse
import datetime as dt
import re
import sys
from dataclasses import dataclass
from pathlib import Path

UNRELEASED_HEADING = "## [Unreleased]"
VERSION_HEADING = re.compile(r"^## \[(\d+\.\d+\.\d+)\]", re.M)
PUBSPEC_VERSION = re.compile(
    r"^version:\s*(\d+)\.(\d+)\.(\d+)\+(\d+)\s*$", re.M
)
CONST_VERSION = re.compile(
    r"(static const String version = ')(\d+\.\d+\.\d+)(';)"
)
CONST_BUILD = re.compile(r"(static const int buildNumber = )(\d+)(;)")
REPO_COMPARE = re.compile(
    r"^\[Unreleased\]: https://github\.com/[^/]+/[^/]+/compare/v[\d.]+...HEAD$",
    re.M,
)


@dataclass(frozen=True)
class Version:
    major: int
    minor: int
    patch: int
    build: int

    @property
    def name(self) -> str:
        return f"{self.major}.{self.minor}.{self.patch}"

    @property
    def full(self) -> str:
        return f"{self.name}+{self.build}"

    def bump(self, kind: str) -> Version:
        if kind == "minor":
            return Version(self.major, self.minor + 1, 0, self.build + 1)
        if kind == "patch":
            return Version(self.major, self.minor, self.patch + 1, self.build + 1)
        raise ValueError(f"unsupported bump {kind}")


@dataclass(frozen=True)
class Unreleased:
    added: list[str]
    changed: list[str]
    fixed: list[str]
    removed: list[str]

    def has_items(self) -> bool:
        return any((self.added, self.changed, self.fixed, self.removed))

    def bump_kind(self) -> str:
        if self.added or self.removed:
            return "minor"
        return "patch"

    def render_section(self, version: str, day: str) -> str:
        blocks = [f"## [{version}] - {day}", ""]
        for title, items in (
            ("Added", self.added),
            ("Changed", self.changed),
            ("Fixed", self.fixed),
            ("Removed", self.removed),
        ):
            if not items:
                continue
            blocks.append(f"### {title}")
            blocks.append("")
            blocks.extend(items)
            blocks.append("")
        return "\n".join(blocks).rstrip() + "\n"


def parse_pubspec_version(text: str) -> Version:
    match = PUBSPEC_VERSION.search(text)
    if not match:
        raise SystemExit("Could not parse version: from pubspec.yaml")
    return Version(*(int(p) for p in match.groups()))


def parse_unreleased(changelog: str) -> Unreleased:
    match = re.search(
        rf"^{re.escape(UNRELEASED_HEADING)}\n(.*?)(?=^## \[|\Z)",
        changelog,
        flags=re.M | re.S,
    )
    if not match:
        raise SystemExit("CHANGELOG.md has no [Unreleased] section")
    body = match.group(1)

    def items(title: str) -> list[str]:
        section = re.search(
            rf"^### {title}\n(.*?)(?=^### |\Z)",
            body,
            flags=re.M | re.S,
        )
        if not section:
            return []
        return [
            line
            for line in section.group(1).splitlines()
            if line.startswith("- ")
        ]

    return Unreleased(
        added=items("Added"),
        changed=items("Changed"),
        fixed=items("Fixed"),
        removed=items("Removed"),
    )


def apply_changelog(
    changelog: str,
    unreleased: Unreleased,
    version: str,
    day: str,
) -> str:
    section = unreleased.render_section(version, day)
    updated = re.sub(
        rf"^{re.escape(UNRELEASED_HEADING)}\n(.*?)(?=^## \[)",
        f"{UNRELEASED_HEADING}\n\n{section}\n",
        changelog,
        count=1,
        flags=re.M | re.S,
    )
    unreleased_link = (
        f"[Unreleased]: https://github.com/arioch1984/tasko/compare/v{version}...HEAD"
    )
    version_link = (
        f"[{version}]: https://github.com/arioch1984/tasko/releases/tag/v{version}"
    )
    updated = REPO_COMPARE.sub(unreleased_link, updated, count=1)
    if f"[{version}]:" not in updated:
        updated = updated.replace(
            unreleased_link + "\n",
            unreleased_link + "\n" + version_link + "\n",
            1,
        )
    return updated


def apply_pubspec(text: str, version: Version) -> str:
    updated, n = PUBSPEC_VERSION.subn(f"version: {version.full}", text, count=1)
    if n != 1:
        raise SystemExit("Could not update pubspec.yaml version")
    return updated


def apply_constants(text: str, version: Version) -> str:
    updated, n1 = CONST_VERSION.subn(rf"\g<1>{version.name}\3", text, count=1)
    updated, n2 = CONST_BUILD.subn(rf"\g<1>{version.build}\3", updated, count=1)
    if n1 != 1 or n2 != 1:
        raise SystemExit("Could not update AppConstants version/buildNumber")
    return updated


def write_github_output(path: Path, values: dict[str, str]) -> None:
    with path.open("a", encoding="utf-8") as handle:
        for key, value in values.items():
            if "\n" in value:
                handle.write(f"{key}<<EOF\n{value}\nEOF\n")
            else:
                handle.write(f"{key}={value}\n")


def prepare(
    root: Path,
    base_pubspec: str,
    today: dt.date,
) -> dict[str, str]:
    changelog_path = root / "CHANGELOG.md"
    pubspec_path = root / "pubspec.yaml"
    constants_path = root / "lib/core/constants.dart"
    changelog = changelog_path.read_text(encoding="utf-8")
    unreleased = parse_unreleased(changelog)
    if not unreleased.has_items():
        return {
            "skip": "true",
            "reason": "No [Unreleased] changelog items to ship",
        }

    base = parse_pubspec_version(base_pubspec)
    nxt = base.bump(unreleased.bump_kind())
    day = today.isoformat()
    changelog_path.write_text(
        apply_changelog(changelog, unreleased, nxt.name, day),
        encoding="utf-8",
    )
    pubspec_path.write_text(
        apply_pubspec(pubspec_path.read_text(encoding="utf-8"), nxt),
        encoding="utf-8",
    )
    constants_path.write_text(
        apply_constants(constants_path.read_text(encoding="utf-8"), nxt),
        encoding="utf-8",
    )
    notes = unreleased.render_section(nxt.name, day)
    body = (
        f"Merging this PR into `main` publishes **v{nxt.name}** "
        f"(signed APK `tasko-{nxt.name}.apk` on GitHub Releases).\n\n"
        f"The release workflow tags `v{nxt.name}` and builds from `main`.\n\n"
        f"{notes}"
    )
    return {
        "skip": "false",
        "version": nxt.name,
        "tag": f"v{nxt.name}",
        "full_version": nxt.full,
        "branch": f"release/v{nxt.name}",
        "title": f"Release v{nxt.name}",
        "body": body,
    }


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, default=Path("."))
    parser.add_argument(
        "--base-pubspec",
        help="pubspec.yaml text from main. Default: git show origin/main:pubspec.yaml",
    )
    parser.add_argument("--github-output", type=Path)
    parser.add_argument("--body-file", type=Path)
    parser.add_argument("--today", help="YYYY-MM-DD override for tests")
    args = parser.parse_args()
    base_pubspec = args.base_pubspec
    if base_pubspec is None:
        import subprocess

        base_pubspec = subprocess.check_output(
            ["git", "show", "origin/main:pubspec.yaml"],
            text=True,
        )
    today = (
        dt.date.fromisoformat(args.today) if args.today else dt.date.today()
    )
    result = prepare(args.root, base_pubspec, today)
    for key, value in result.items():
        if key != "body":
            print(f"{key}={value}")
    if args.github_output:
        write_github_output(args.github_output, result)
    if args.body_file and result.get("body"):
        args.body_file.write_text(result["body"], encoding="utf-8")
    if result.get("skip") == "true":
        sys.exit(0)


if __name__ == "__main__":
    main()
