#!/bin/bash
$git_count=$(git rev-list --count master)
echo "Rolling out +$git_count ..."
flutter clean && flutter pub get
flutter build ios --release --build-number="$git_count"
flutter build aab --release --build-number="$git_count"
cd ios || exit
fastlane release
cd .. || exit
cd android || exit
fastlane release
cd .. || exit

# upload_to_play_store