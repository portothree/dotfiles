# Juju

## Overview

Laptop for work on the go running NixOS.

## Specs

Huawei Matebook D14

## Installation


## `ledger.nix`

Required udev rules to make Ledger Nano S work with NixOS, they are applied to the `plugdev` group which the user `porto` is added.
After updating a rule, make sure to run the following to make sure the rules were applied:

```
udevadm trigger
udevadm control --reload-rules
```
