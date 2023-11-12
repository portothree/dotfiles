# Boris

## Overview

Travel laptop

## Specs

2023 MacBook M3 Pro

## Installation

`$ nix run nix-darwin -- switch --flake .`
or
`$ darwin-rebuild switch --flake .`

## Tricks

### Hide Dock

`$ defaults write com.apple.dock autohide-delay -float 1000; killall Dock`
