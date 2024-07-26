flutter clean && flutter pub get
flutter build ios --release
cd ios || exit
fastlane release
cd .. || exit