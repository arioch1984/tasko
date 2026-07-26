# Changelog

All notable changes to Tasko are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

[Unreleased]: https://github.com/arioch1984/tasko/compare/v0.1.1...HEAD
[0.1.1]: https://github.com/arioch1984/tasko/releases/tag/v0.1.1
[0.1.0]: https://github.com/arioch1984/tasko/releases/tag/v0.1.0
