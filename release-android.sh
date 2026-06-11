#!/bin/bash
git pull
git_count=$(git rev-list --count main)

flutter build aab --release --build-number="$git_count"
cd android || exit
bundler exec fastlane release
cd .. || exit