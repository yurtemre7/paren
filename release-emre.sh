#!/bin/bash
git pull
git_count=$(git rev-list --count HEAD)
echo "==> Rolling out +$git_count ..."

echo "==> Do you want to release all [0], ios [1], android [2]?"
echo "==> Enter number: "

read selection

if [[ ! $selection =~ ^[0-9]+$ ]] ; then
    echo "==> This was not a number. Retry."
    exit
fi

echo "==> flutter doctor --verbose"
flutter doctor --verbose
echo "==> flutter clean && flutter pub get"
flutter clean && flutter pub get

if [ $selection = "0" ] ; then
    echo "==> Pushing all"
    echo ""
    echo "==> Pushing ios"
    ./release-ios.sh
    echo ""
    echo "==> Pushing android"
    ./release-android.sh
    echo ""
    echo "==> Done"
fi

if [ $selection = "1" ] ; then
    echo "==> Pushing ios"
    ./release-ios.sh
    echo ""
    echo "==> Done"
fi

if [ $selection = "2" ] ; then
    echo "==> Pushing android"
    ./release-android.sh
    echo ""
    echo "==> Done"
fi