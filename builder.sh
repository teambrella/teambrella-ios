#!/bin/bash

#sudo xcode-select -s /Applications/Xcode.app/Contents/Developer

echo "Checking whether all necessary programms are installed..."
if gem list pod -i > /dev/null; then
  echo "Cocoapods is installed"
else
  echo "Installing Cocoapods"
  gem install cocoapods
fi

command -v brew >/dev/null 2>&1 || { echo >&2 "Installing Homebrew"; \
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"; }

if brew ls --versions carthage > /dev/null; then
  echo "Carthage is installed"
else
  echo "Installing Carthage"
  brew install carthage
fi

echo "Retreiving carthage dependencies. This may take a while..."
carthage update --platform iOS
echo "Retreiving Cocoapods dependencies. This should be quite fast..."
pod install

resources="Resources"
if test "$(ls "$resources")"; then
     echo "$resources already populated"
else
    echo "$resources folder is Empty. Cloning private repo..."
    git submodule init
    git submodule update
    echo "Finished cloning private resources."
fi

echo "Teambrella is ready to use"
say -v Milena Сборка проэкта Тимбрэлла, завершена
