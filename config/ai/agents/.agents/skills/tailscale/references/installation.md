# Installation

## Linux (mainstream distributions)

Works on Ubuntu, Debian, RHEL, CentOS, Fedora, Raspberry Pi OS, Amazon Linux, openSUSE, Oracle Linux, and VMware Photon OS.

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

The `tailscale up` command prints a URL to authenticate. Open it in a browser to add the device to your tailnet.

### Verify installation

```bash
tailscale ip        # Shows your Tailscale IPv4 and IPv6 addresses
tailscale status    # Shows connection status and other devices
```

### Arch Linux and NixOS

These distributions have their own packages — install `tailscale` through `pacman` or your NixOS configuration respectively.

### Static binaries

For distributions not supported by the install script:

```bash
# Download for your architecture from https://pkgs.tailscale.com/stable/
tar xvf tailscale_<version>_<architecture>.tgz

# Start the daemon
sudo tailscaled --state=tailscaled.state

# Connect
sudo tailscale up
```

A systemd service file is included in the `systemd/` subdirectory of the archive.

## macOS

Three variants are available:

1. **Mac App Store** — GUI app, sandboxed, most common for personal use
2. **Standalone (GUI)** — Downloaded from http://tailscale.com/download, same GUI but not sandboxed
3. **Open source CLI (`tailscaled`)** — Command-line only, required for Tailscale SSH server

Download from https://tailscale.com/download/mac or the Mac App Store.

For CLI access with the GUI variants, enable CLI integration in the Tailscale menu, or invoke directly:
```bash
/Applications/Tailscale.app/Contents/MacOS/Tailscale <command>
```

## Windows

Download from https://tailscale.com/download/windows or install via MSI for enterprise deployment.

WSL 2 is also supported; refer to the Tailscale docs for WSL 2 instructions.

## iOS and Android

Install from the Apple App Store or Google Play Store respectively. Authentication happens in-app.

## Updating

- **CLI**: `tailscale update`
- **GUI apps**: Update through the app or app store
- **Auto-update**: Configurable from the admin console or via MDM policies

## Uninstalling

Refer to Tailscale's uninstall documentation for platform-specific removal steps. On Linux, use your package manager (`apt remove tailscale`, `yum remove tailscale`).
