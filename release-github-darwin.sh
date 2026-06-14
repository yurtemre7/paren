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
flutter build macos --release --build-number="$git_count"

IPA_PATH="$(find build/ios/ipa -maxdepth 1 -type f -name '*.ipa' -print0 | xargs -r -0 ls -t | head -n 1)"
APP_PATH="$(find build/macos/Build/Products/Release -maxdepth 1 -type f -name '*.app' -print0 | xargs -r -0 ls -t | head -n 1)"

if [[ -z "$IPA_PATH" || ! -f "$IPA_PATH" ]]; then
  echo "Error: no IPA found in build/ios/ipa." >&2
  exit 1
fi

if [[ -z "$APP_PATH" || ! -f "$APP_PATH" ]]; then
  echo "Error: no APP found in build/macos/Build/Products/Release." >&2
  exit 1
fi

TAG="$(gh release view -R "$REPO" --json tagName --jq .tagName)"

if [[ -z "$TAG" ]]; then
  echo "Error: could not find the latest release in $REPO." >&2
  exit 1
fi

echo "==> Uploading $(basename "$IPA_PATH") to release $TAG"
gh release upload "$TAG" "$IPA_PATH" -R "$REPO" --clobber
echo "==> Uploading $(basename "$APP_PATH") to release $TAG"
gh release upload "$TAG" "$APP_PATH" -R "$REPO" --clobber

echo "==> Done"