#!/usr/bin/env bash
# Idempotent Cloud Agent bootstrap for the Tasko Flutter app.
# Installs a pinned Flutter SDK (web target) and fetches project dependencies.
set -euo pipefail

FLUTTER_VERSION="3.47.0"
FLUTTER_ROOT="/opt/flutter"
FLUTTER_ARCHIVE="flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${FLUTTER_ARCHIVE}"

log() { printf '\n\033[1;36m==> %s\033[0m\n' "$1"; }

# Resolve the repo root as the directory containing this script's parent (.cursor/..).
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

install_flutter() {
  if [ -x "${FLUTTER_ROOT}/bin/flutter" ]; then
    log "Flutter already present at ${FLUTTER_ROOT} (skipping download)"
    return
  fi
  log "Installing Flutter ${FLUTTER_VERSION} to ${FLUTTER_ROOT}"
  sudo mkdir -p "${FLUTTER_ROOT}"
  sudo chown -R "$(id -un):$(id -gn)" "${FLUTTER_ROOT}"
  tmp="$(mktemp -d)"
  curl -fsSL -o "${tmp}/${FLUTTER_ARCHIVE}" "${FLUTTER_URL}"
  # Extract into the parent so the tarball's top-level "flutter" dir maps onto FLUTTER_ROOT.
  tar -xf "${tmp}/${FLUTTER_ARCHIVE}" -C "$(dirname "${FLUTTER_ROOT}")"
  rm -rf "${tmp}"
}

configure_flutter() {
  log "Configuring Flutter toolchain"
  # Flutter shells out to git internally; trust its own checkout.
  git config --global --add safe.directory "${FLUTTER_ROOT}" || true

  export PATH="${FLUTTER_ROOT}/bin:${PATH}"

  # Put flutter/dart on the default PATH for every future shell.
  sudo ln -sf "${FLUTTER_ROOT}/bin/flutter" /usr/local/bin/flutter
  sudo ln -sf "${FLUTTER_ROOT}/bin/dart" /usr/local/bin/dart

  # Persist a Chrome executable for `flutter run -d chrome` in interactive shells.
  if [ -x /usr/local/bin/google-chrome ]; then
    printf 'export CHROME_EXECUTABLE=/usr/local/bin/google-chrome\n' \
      | sudo tee /etc/profile.d/flutter-chrome.sh >/dev/null
    export CHROME_EXECUTABLE=/usr/local/bin/google-chrome
  fi

  flutter --disable-analytics >/dev/null 2>&1 || true
  flutter config --no-cli-animations --enable-web >/dev/null 2>&1 || true
}

fetch_dependencies() {
  log "Fetching project dependencies (flutter pub get)"
  cd "${REPO_ROOT}"
  flutter pub get
  # Warm the web engine artifacts so the first web build/run is fast.
  flutter precache --web >/dev/null 2>&1 || true
}

install_flutter
configure_flutter
fetch_dependencies

log "Flutter environment ready"
flutter --version
