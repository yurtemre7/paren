#!/bin/bash
git pull
git_count=$(git rev-list --count HEAD)

flutter build web --build-number="$git_count"
rsync -avhz ./build/web/ ./docs/
git add .
git commit -m "update website"
git push
git pull