# APK releases

Ship Android builds through **GitHub Releases**. Do not commit binary APKs to this folder.

## Checklist (matches `main` release rule)

1. Bump `pubspec.yaml` and `AppConstants.version` / `buildNumber`
2. Update `CHANGELOG.md`
3. Merge/commit to `main` and tag `vX.Y.Z`
4. `flutter build apk --release`
5. Rename to `tasko-X.Y.Z.apk`
6. Create a GitHub Release for tag `vX.Y.Z`, paste the changelog section, attach the APK

Users download from the repo Releases page (see README Downloads).
