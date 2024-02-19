# Boris

## Overview

Travel laptop

## Specs

2023 MacBook M3 Pro

## Installation

`$ nix run nix-darwin -- switch --flake .`
or
`$ darwin-rebuild switch --flake .`

## Preparation

### Keyboard

- Disable all shortcuts in System Preferences > Keyboard > Shortcuts
- Change modifier keys to replace Command with Control

## Other

### Hide Dock

`$ defaults write com.apple.dock autohide-delay -float 1000; killall Dock`
