#!/bin/bash
git_count=$(git rev-list --count main)
flutter clean && flutter pub get
flutter build aab --release --build-number="$git_count"
cd android || exit
fastlane release
cd .. || exit