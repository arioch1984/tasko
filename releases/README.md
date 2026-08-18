# APK releases

Ship Android builds through **GitHub Releases**. Do not commit binary APKs to this folder.

Pushing an annotated tag `vX.Y.Z` on a commit that contains `.github/workflows/release.yml` builds a signed APK and creates the GitHub Release. Manual `flutter build` / upload is only a fallback.

## Checklist (matches `main` release rule)

1. Bump `pubspec.yaml` and `AppConstants.version` / `buildNumber`
2. Update `CHANGELOG.md`
3. Merge/commit to `main` and tag `vX.Y.Z`
4. Push the tag — Actions attaches `tasko-X.Y.Z.apk` to the GitHub Release

Users download from the repo Releases page (see README Downloads).

## Local signing (optional)

CI uses repository Actions secrets (`ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_PASSWORD`) and the `ANDROID_KEY_ALIAS` Actions variable.

To sign locally with the same keystore, create gitignored `android/key.properties`:

```properties
storePassword=...
keyPassword=...
keyAlias=tasko
storeFile=/path/to/tasko-release.jks
```
