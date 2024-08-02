#!/bin/bash
git_count=$(git rev-list --count main)
flutter clean && flutter pub get
flutter build ios --release --build-number="$git_count"
cd ios || exit
fastlane release
cd .. || exit