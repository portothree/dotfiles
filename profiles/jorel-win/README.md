# Jorel

## Overview

Main workstation.
- Windows
- Uses scoop package manager (https://scoop.sh)
- Komorebi window tiling manager (https://github.com/LGUG2Z/komorebi)
- TODO: Explore AutoHotkey (https://www.autohotkey.com/)

## Specs

## Installation

### Install scoop

```
> Set-ExecutionPolicy RemoteSigned -Scope CurrentUser # Optional: Needed to run a remote script the first time
> irm get.scoop.sh | iex
```

### Install Komorebi

Enable support for long paths in Windows by running the following command in an Administrator Terminal
```
> Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem' -Name 'LongPathsEnabled' -Value 1
```

```
> scoop bucket add extras
> scoop install whkd
> scoop install komorebi

# save the example configuration to ~/komorebi.json
> iwr https://raw.githubusercontent.com/LGUG2Z/komorebi/master/komorebi.example.json -OutFile $Env:USERPROFILE\komorebi.json

# save the latest generated app-specific config tweaks and fixes
> komorebic fetch-app-specific-configuration

# ensure the ~/.config folder exists
> mkdir $Env:USERPROFILE\.config -ea 0

# save the sample whkdrc file with key bindings to ~/.config/whkdrc
> iwr https://raw.githubusercontent.com/LGUG2Z/komorebi/master/whkdrc.sample -OutFile $Env:USERPROFILE\.config\whkdrc

# start komorebi and whkd
> komorebic start -c $Env:USERPROFILE\komorebi.json --whkd
```