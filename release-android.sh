#!/bin/bash
git pull
git_count=$(git rev-list --count main)

echo "==> flutter build aab --release --build-number='$git_count'"
flutter build aab --release --build-number="$git_count"
cd android || exit
echo "==> bundler exec fastlane release"
bundler exec fastlane release
cd .. || exit