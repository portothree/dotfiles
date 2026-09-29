# Boris

https://irmaodojorel.fandom.com/pt-br/wiki/B%C3%B3ris

## Overview

Travel laptop

## Specs

2023 MacBook Pro M3

## Installation

`$ ./setup boris` (see the repo README)
or
`$ darwin-rebuild switch --flake .`

## Preparation

### Keyboard

- Disable all shortcuts in System Preferences > Keyboard > Shortcuts
- Change modifier keys to replace Command with Control

## Other

### Hide Dock

`$ defaults write com.apple.dock autohide-delay -float 1000; killall Dock`
