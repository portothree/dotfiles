# dotfiles

It uses [home-manager](https://github.com/nix-community/home-manager) to install and create programs configurations based off the `home.nix` file.

![Current desk screenshot](https://i.imgur.com/ti2LDBF.png)

[Home Manager Manual](https://nix-community.github.io/home-manager/)

## NixOs

```
mkdir -p /mnt/etc/nixos
nix-shell '<nixpkgs>' -p git vim
git clone https://github.com/portothree/dotfiles /mnt/etc/nixos


nix-channel --add https://github.com/nix-community/home-manager/archive/release-21.11.tar.gz home-manager
nix-channel --update

nixos-generate-config --show-hardware-config >> /mnt/etc/nixos/hosts/<host>/hardware-configuration.nix
nixos-install -I nixos-config=/mnt/etc/nixos/hosts/<host>/hardware-configuration.nix
reboot
```

## Non-NixOs

### Debian + Nix as package manager(?)

For my non-nixos machines I'm currently using debian `apt` strictly for the base system, and Nix for all userspace apps.

### Usage

Make sure `nix` and `home-manager` is installed.

```
$ nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
$ nix-channel --update
$ export NIX_PATH = "$HOME/.nix-defexpr/channels:/nix/var/nix/profiles/per-user/root/channels";
$ nix-shell '<home-manager>' -A install
```

Create a symbolic link of `./config/nixos/hosts/<host>/home.nix` at `$HOME/.config/nixpkgs/home.nix`.

```
$ ln home.nix $HOME/.config/nixpkgs/home/nix
```

Run `home-manager switch`

### Text editor

#### vim

-   [Vim prettier](https://github.com/prettier/vim-prettier)
-   [Vim Polyglot](https://github.com/sheerun/vim-polyglot)
-   [Vim-airline](https://github.com/vim-airline/vim-airline)
-   [Dracula for vim](https://github.com/dracula/vim)
-   [YouCompleteMe](https://github.com/ycm-core/YouCompleteMe)
-   [ALE](https://github.com/dense-analysis/ale)
-   [vim-jsdoc](https://github.com/heavenshell/vim-jsdoc)
-   [emmet-vim](https://github.com/mattn/emmet-vim)
-   [NERDTree](https://github.com/preservim/nerdtree)
-   [Node Inspect](https://github.com/eliba2/vim-node-inspect)
-   [Editorconfig](https://github.com/editorconfig/editorconfig-vim)
-   [DirDiff](https://github.com/will133/vim-dirdiff)


# Link dump

-   https://vimawesome.com/
-   https://github.com/wting/autojump
-   https://github.com/keepcosmos/terjira
-   https://github.com/vit-project/vit
-   https://github.com/ggreer/the_silver_searcher
-   https://github.com/junegunn/fzf
-   https://tldr.sh/

# Shell scripts

Handful collection of shell scripts inspired by https://github.com/salman-abedin/alfred

# Hardware

## AMD Wraith Prism
- https://github.com/serebit/wraith-master
- https://gitlab.com/serebit/wraith-master
- https://github.com/gfduszynski/cm-rgb


# FAQ

Home manager and flakes with Non-NixOS systems
- https://dee.underscore.world/blog/home-manager-flakes/
