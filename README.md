# Teambrella iOS Client

<a href="https://github.com/apple/swift"><img src="https://img.shields.io/badge/Swift-4.1-F16D39.svg?style=flat"></a>

## Synopsis

This is an iOS client for Teambrella project.

## Features

- Automatic payment of reimbursements and withdrawals
- Control and prevention of suspicious transactions

## Installation

You need to download additional libraries before compiling this project.
To do so you first need to have [Cocoapods](https://cocoapods.org)
and [Carthage](https://github.com/Carthage/Carthage) installed.

Then you need to execute a simple script **builder.sh** to do so go to the project 
root folder in terminal and execute `./builder.sh`

## Warning

The client stores private keys locally and backs them up via Apple iCloud service. Private keys are never sent to Teambrella server. So it is the client's responsibility to back them up. There is no possibility to restore the key by Teambrella.

## Components

| Folder | Description |
|---|---|
| Blockchain | Services managing communication with Ethereum network and storing data about transactions and users locally |
| notification | Push notification extension to handle rich notifications |
| Teambrella | Main application's bundle |
| External | Separate files that are not originated in our dev lab |
