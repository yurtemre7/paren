#!/bin/bash
git pull
git_count=$(git rev-list --count main)

flutter build ios --release --build-number="$git_count"
cd ios || exit
bundler exec fastlane release
cd .. || exit
git add ./ios/
git commit -m "chore: update ios version"
git push
git pull