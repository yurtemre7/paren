#!/bin/bash
git pull
git_count=$(git rev-list --count main)

flutter clean && flutter pub get
flutter build ios --release --build-number="$git_count"
cd ios || exit
fastlane release
cd .. || exit
git add ./ios/
git commit -m "update ios version"
git push
git pull