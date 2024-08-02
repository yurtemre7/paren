#!/bin/bash
git_count=$(git rev-list --count HEAD)
echo "Rolling out +$git_count ..."

./release-ios.sh
./release-android.sh