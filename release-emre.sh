git pull
flutter clean && flutter pub get
flutter build ios --release
cd ios || exit
fastlane release
cd .. || exit
git add .
git commit -m "update ios build number"
git push
git pull