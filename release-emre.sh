#!/bin/bash
git_count=$(git rev-list --count HEAD)
echo "Rolling out +$git_count ..."

echo "Do you want to release all [0], ios [1], android [2] or web [3]?"
echo "Enter number: "

read selection

if [[ ! $selection =~ ^[0-9]+$ ]] ; then
    echo "This was not a number. Retry."
    exit
fi

if [ $selection = "0" ] ; then
    ./release-ios.sh
    ./release-android.sh
    ./release-web.sh
fi

if [ $selection = "1" ] ; then
    ./release-ios.sh
fi

if [ $selection = "2" ] ; then
    ./release-android.sh
fi

if [ $selection = "3" ] ; then
    ./release-web.sh
fi