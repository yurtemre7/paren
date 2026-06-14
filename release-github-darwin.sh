#!/usr/bin/env bash
set -euo pipefail

git_count=$(git rev-list --count main)

REPO="yurtemre7/paren"

if [[ ! -f pubspec.yaml ]]; then
  echo "Error: run this script from your Flutter project root." >&2
  exit 1
fi

echo "==> flutter build ipa --release --build-number='$git_count'"
flutter build ipa --release --build-number="$git_count"

echo "==> flutter build macos --release --build-number='$git_count'"
flutter build macos --release --build-number="$git_count"

# --- IPA (safe discovery) ---
ipa_files=()
while IFS= read -r -d '' file; do
  ipa_files+=("$file")
done < <(find build/ios/ipa -maxdepth 1 -type f -name '*.ipa' -print0)

if [[ ${#ipa_files[@]} -eq 0 ]]; then
  echo "Error: no IPA found in build/ios/ipa." >&2
  exit 1
fi
IPA_PATH="$(ls -t "${ipa_files[@]}" | head -n 1)"

# --- macOS .app → zip ---
APP_PATH="$(find build/macos/Build/Products/Release -maxdepth 1 -type d -name '*.app' | head -n 1)"

if [[ -z "$APP_PATH" ]]; then
  echo "Error: no .app found in build/macos/Build/Products/Release." >&2
  exit 1
fi

APP_NAME="$(basename "$APP_PATH" .app)"
ZIP_PATH="build/macos/Build/Products/Release/${APP_NAME}.zip"

echo "==> Zipping ${APP_NAME}.app → ${APP_NAME}.zip"
ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" "$ZIP_PATH"

# --- Upload ---
TAG="$(gh release view -R "$REPO" --json tagName --jq .tagName)"

if [[ -z "$TAG" ]]; then
  echo "Error: could not find the latest release in $REPO." >&2
  exit 1
fi

echo "==> Uploading $(basename "$IPA_PATH") to release $TAG"
gh release upload "$TAG" "$IPA_PATH" -R "$REPO" --clobber

echo "==> Uploading ${APP_NAME}.zip to release $TAG"
gh release upload "$TAG" "$ZIP_PATH" -R "$REPO" --clobber

echo "==> Done"
