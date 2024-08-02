#!/bin/bash
git pull
git_count=$(git rev-list --count HEAD)
echo "Rolling out +$git_count ..."

flutter build web --build-number="$git_count"
rsync -avhz ./build/web/ ./docs/
git add .
git commit -m "update website"
git push
git pull