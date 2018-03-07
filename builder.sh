#!/bin/bash

sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
carthage update --platform iOS
pod update
say Сборка проэкта Тимбрэлла, завершена
