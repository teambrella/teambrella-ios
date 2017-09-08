#!/bin/bash

sudo xcode-select -s /Applications/Xcode-beta.app/Contents/Developer
carthage update --platform iOS
pod install
say Сборка проэкта Тимбрэлла бета ай ось одиннадцать, завершена
