#!/bin/bash
git pull
git_count=$(git rev-list --count main)

echo "==> flutter build ios --release --build-number='$git_count'"
flutter build ios --release --build-number="$git_count"
cd ios || exit
echo "==> bundler exec fastlane release"
bundler exec fastlane release
cd .. || exit
./release-github-ipa.sh
git add ./ios/
git commit -m "chore: update ios version"
git push
git pull