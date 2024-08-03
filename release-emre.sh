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
    echo "Pushing all"
    echo ""
    echo "Pushing ios"
    ./release-ios.sh
    echo ""
    echo "Pushing android"
    ./release-android.sh
    echo ""
    echo "Pushing web"
    ./release-web.sh
    echo ""
    echo "Finished"
fi

if [ $selection = "1" ] ; then
    echo "Pushing ios"
    ./release-ios.sh
    echo ""
    echo "Finished"
fi

if [ $selection = "2" ] ; then
    echo "Pushing android"
    ./release-android.sh
    echo ""
    echo "Finished"
fi

if [ $selection = "3" ] ; then
    echo "Pushing web"
    ./release-web.sh
    echo ""
    echo "Finished"
fi