#!/bin/bash
git pull
git_count=$(git rev-list --count HEAD)

flutter clean && flutter pub get
flutter build web --build-number="$git_count" --wasm
rsync -avhz ./build/web/ /Users/yurtemre/Code/FlutterProjects/yurtemre_deno/static/iparen
cd /Users/yurtemre/Code/FlutterProjects/yurtemre_deno/
git pull
git add .
git commit -m "update website"
git push
git pull