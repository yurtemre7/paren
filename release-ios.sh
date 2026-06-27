#!/bin/bash
git pull
git_count=$(git rev-list --count main)

cd ios || exit
echo "==> bundler exec fastlane release"
bundler exec fastlane release || exit
cd .. || exit
git add ./ios/
git commit -m "chore: update ios version"
git push
git pull