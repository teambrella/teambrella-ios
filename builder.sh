#!/bin/bash

sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
carthage update --platform iOS
pod install
say Сборка проекта "ТимбрЭлла" - завершена
