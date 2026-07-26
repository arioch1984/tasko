# Tasko

Improved Android UI for **Google Tasks**: priority, labels, sorting, and smart views (Today / Upcoming). Tasks live only on Google Tasks — Tasko is the interface.

Mascot: **Tasko the badger** (*tasso* + *task*).

Primary language: **English** (docs, UI, changelog). Localization can be added later without rewriting call sites — see `lib/core/l10n/app_strings.dart`.

## Downloads (APK)

Prebuilt Android APKs are published on **GitHub Releases**:

- Latest release: <https://github.com/arioch1984/tasko/releases/latest>
- All versions: <https://github.com/arioch1984/tasko/releases>

Each release is tagged (`vX.Y.Z`), lists changes in [CHANGELOG.md](CHANGELOG.md), and attaches a versioned APK (e.g. `tasko-0.1.1.apk`). Install from Releases until another distribution channel is set up.

### Build a release APK locally

```bash
flutter build apk --release
# output: build/app/outputs/flutter-apk/app-release.apk
# rename before upload, e.g. tasko-0.1.1.apk
```

## Stack

- Flutter (**Android** primary target)
- Riverpod + go_router
- Google Sign-In + Google Tasks API v1

Do not use Chrome / web for day-to-day development: `google_sign_in` on web requires a Web OAuth client ID and will assert without it. Use a device or emulator.

## Setup Google Cloud (required)

End users never open Google Cloud — only the app developer does this once.

1. Create a project in [Google Cloud Console](https://console.cloud.google.com/)
2. Enable **Google Tasks API**
3. Configure the **OAuth consent screen** (External; Testing mode is fine in development)
4. Create **OAuth client ID → Android**:
   - Package name: `com.tasko.tasko` (see [`android/app/build.gradle.kts`](android/app/build.gradle.kts))
   - SHA-1 of the **debug** keystore (see below)

The Android client ID is **not** pasted into the Dart code. Google matches the app by package name + SHA-1 via Play Services.

Required scope: `https://www.googleapis.com/auth/tasks`

### Optional: Web OAuth client

Create a **Web** OAuth client only if:

- you need `serverClientId` because Android sign-in succeeds but `accessToken` is null, or
- you intentionally run the Flutter **web** target

Then set it in [`lib/auth/auth_provider.dart`](lib/auth/auth_provider.dart):

```dart
GoogleSignIn(
  scopes: const [AppConstants.tasksScope],
  // serverClientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com', // Android helper
  // clientId: 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com',       // web target only
);
```

For web you can instead add a meta tag in `web/index.html`:

```html
<meta name="google-sign-in-client_id" content="YOUR_WEB_CLIENT_ID.apps.googleusercontent.com" />
```

### Debug SHA-1

Needs a JDK (`keytool`). On macOS, Homebrew OpenJDK works if the system Java stub fails:

```bash
# macOS example
export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"

# Create the debug keystore if it does not exist yet
mkdir -p ~/.android
keytool -genkey -v \
  -keystore ~/.android/debug.keystore \
  -storepass android -keypass android \
  -alias androiddebugkey -keyalg RSA -keysize 2048 -validity 10000 \
  -dname "CN=Android Debug,O=Android,C=US"

keytool -list -v -alias androiddebugkey \
  -keystore ~/.android/debug.keystore \
  -storepass android -keypass android
```

Copy the `SHA1:` line into the Android OAuth client in Cloud Console.

A **release** APK uses a different keystore — register that SHA-1 too before shipping signed builds.

## Run

```bash
export PATH="$HOME/development/flutter/bin:$PATH"
# If using Homebrew Android cmdline-tools:
# export ANDROID_HOME="/opt/homebrew/share/android-commandlinetools"
# export JAVA_HOME="/opt/homebrew/opt/openjdk@17"
# export PATH="$JAVA_HOME/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"

cd /path/to/Tasko
flutter pub get
flutter devices
flutter run -d emulator-5554   # or your device id — avoid chrome
```

Add a Google account on the emulator/device before signing in to Tasko.

## Versioning & branches

| Branch    | Role                                      |
|-----------|-------------------------------------------|
| `main`    | Release lineage only (versioned + tagged) |
| `develop` | Day-to-day development                    |

Every commit that lands on `main` must:

1. Bump `version` in `pubspec.yaml` (and `AppConstants.version` / `buildNumber`)
2. Update [CHANGELOG.md](CHANGELOG.md)
3. Create an annotated git tag `vX.Y.Z`
4. Publish a GitHub Release with the changelog notes and the matching APK

See `.cursor/rules/release-versioning.mdc` for the agent checklist.

## Tasko metadata (priority + labels)

Google Tasks has no native priority/label fields. Tasko stores them at the start of `notes`:

```text
[tasko]{"p":2,"l":["work","urgent"]}[/tasko]
User-visible notes follow normally.
```

- `p`: priority 1–4 (1 = highest)
- `l`: label slugs

In Tasko the block is hidden. In the official Google Tasks app it appears as text.

### Label catalog

Reserved list `__Tasko` with a task `Tasko Config` whose `notes` contain:

```json
{"labels":[{"id":"work","name":"Work","color":4281234567}]}
```

## MVP features

- Google sign-in + list/task sync
- Priority P1–P4 and colored labels
- Sorting: due date, priority, title, manual (position API)
- Filter by label
- **Today** and **Upcoming** (7 days) views
- Empty states and celebrate moments with Tasko mascot

## Known API limits

- Due date: day only (API drops time)
- One level of subtasks
- No list sharing / assignees
- In OAuth “Testing”, refresh tokens expire after ~7 days until the app is in production
- Pagination: max 100 items per page (Tasko pages automatically)

## Structure

```text
lib/
  auth/           # Google Sign-In
  core/           # theme, router, mascot, l10n strings
  data/           # API, codec, repository, providers
  domain/         # models
  features/       # UI (sign-in, home, tasks, labels)
assets/mascot/    # Tasko poses
```
