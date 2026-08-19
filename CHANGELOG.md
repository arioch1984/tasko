# Changelog

All notable changes to Tasko are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Tasko the badger mascot redrawn in a stylized cartoon style (bold outlines, flat colors) replacing the 3D renders, including the launcher icon, web icons, and in-app poses
- Drawer header shows Tasko's head instead of the full sitting pose

## [0.3.0] - 2026-08-18

### Added

- Settings for Today: keep overdue on Today, or split them into a separate Overdue drawer item
- Configurable reschedule shortcuts for overdue tasks (single task or bulk), with Pick a date as a fallback

### Changed

- Date pickers start the week on Monday

### Fixed

- Tasko the badger mascot no longer sits on a white rectangle in dark theme (transparent PNGs)

## [0.2.0] - 2026-08-18

### Added

- Dark mode with a warm charcoal palette that matches the existing Tasko theme
- Appearance setting: follow the device by default, or force Light / Dark (saved on-device)

## [0.1.2] - 2026-08-18

### Added

- GitHub Actions builds a signed release APK and publishes it to GitHub Releases when a `vX.Y.Z` tag is pushed
- Android release signing from CI secrets (or local `android/key.properties`); debug signing remains the local fallback

### Changed

- Tagging `vX.Y.Z` on `main` is enough to ship the APK — no manual `flutter build` upload step

## [0.1.1] - 2026-07-26

### Added

- App launcher icon featuring Tasko the badger (adaptive icon on Android)

### Changed

- README Downloads links point to `arioch1984/tasko`
- Developer setup docs: Android-first run target, optional Web OAuth, debug SHA-1 with JDK

## [0.1.0] - 2026-07-26

### Added

- Initial Flutter Android app for Google Tasks (sign-in, lists, tasks sync)
- Priority (P1–P4) and colored labels stored in a hidden Tasko metadata block
- Sort modes: due date, priority, title, manual
- Label filter chips
- Smart views: Today and Upcoming (7 days)
- Empty states and celebrate overlay with Tasko the badger mascot
- English as the primary app and documentation language (i18n-ready string layer)
- Local git workflow: `main` for releases, `develop` for day-to-day work
- Versioning policy: every `main` release bumps version, updates this changelog, and gets a git tag
- APK distribution via GitHub Releases (see README Downloads)

[Unreleased]: https://github.com/arioch1984/tasko/compare/v0.3.0...HEAD
[0.3.0]: https://github.com/arioch1984/tasko/releases/tag/v0.3.0
[0.2.0]: https://github.com/arioch1984/tasko/releases/tag/v0.2.0
[0.1.2]: https://github.com/arioch1984/tasko/releases/tag/v0.1.2
[0.1.1]: https://github.com/arioch1984/tasko/releases/tag/v0.1.1
[0.1.0]: https://github.com/arioch1984/tasko/releases/tag/v0.1.0
