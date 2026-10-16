# Exit Nodes

An exit node routes all non-Tailscale internet traffic through a specific device on your tailnet, similar to a traditional VPN. By default Tailscale only handles traffic between tailnet devices — enabling an exit node extends this to all internet traffic.

## When to use exit nodes

- Securing traffic on untrusted Wi-Fi (coffee shops, hotels)
- Accessing region-locked services from abroad
- Meeting compliance requirements that mandate VPN use
- Testing applications from different geographic locations

## Prerequisites

- Tailscale v1.20+ on both exit node and client devices
- Exit node must be Linux, macOS, Windows, Android, or tvOS
- Access control policies must permit exit node usage (the default policy enables it)

## Setup by platform

Install Tailscale on both the exit node and client devices first (refer to `references/installation.md`), then follow the platform-specific steps below.

### Linux (recommended — best performance)

Linux uses kernel-level routing, which is the most performant option.

1. **Enable IP forwarding:**
   ```bash
   echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
   echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
   sudo sysctl -p /etc/sysctl.d/99-tailscale.conf
   ```

2. **Advertise as exit node:**
   ```bash
   sudo tailscale set --advertise-exit-node
   ```

3. **If using `firewalld`**, you may need:
   ```bash
   firewall-cmd --permanent --add-masquerade
   ```

### macOS

From the Tailscale menu: **Exit Node > Run Exit Node**.

Uses userspace routing (less performant than Linux). Prevent the machine from sleeping to keep the exit node available.

### Windows

From the system tray: **Exit node > Run exit node**.

Uses userspace routing. Enable "Run Unattended" so Tailscale persists after logout. Prevent sleep for continuous availability.

### Android

Open Tailscale app > **Exit Node** > **Run as exit node**.

Battery-intensive; keep the device plugged in. Performance is limited by userspace routing.

## Approving an exit node

An admin must approve the exit node from the admin console:

1. Go to the **Machines** page
2. Find the device with the **Exit Node** badge
3. Open the device menu > **Edit route settings** > enable **Use as exit node**

This step can be skipped if `autoApprovers` are configured in your tailnet policy file.

## Using an exit node (client side)

### Linux
```bash
sudo tailscale set --exit-node=<exit-node-ip>

# With local network access:
sudo tailscale set --exit-node=<exit-node-ip> --exit-node-allow-lan-access=true

# Stop using exit node:
sudo tailscale set --exit-node=
```

### macOS
Tailscale menu > **Exit Nodes** > select the exit node device.

### Windows
System tray > Tailscale > **Use exit node** > select the device.

### iOS / Android
In the Tailscale app, go to **Exit Node** and select the device.

## Local network access

By default, using an exit node blocks access to your local network. To keep local network access:
- **CLI**: `--exit-node-allow-lan-access=true`
- **GUI**: Toggle "Allow Local Network Access" / "Allow LAN access"

## Suggested and automatic exit nodes

Tailscale can suggest the best exit node based on location and latency, or you can enforce exit node usage via MDM system policies.

## Destination logging

Enterprise plans can enable destination logging for exit node traffic in the admin console under **Logs > Network flow logs**. Requires log streaming to be enabled first.

## Caveats

- **macOS/Windows/Android**: Use userspace routing — less performant than Linux's kernel routing
- **macOS/Windows**: Prevent sleep to keep exit node available
- **Android**: Significant battery impact; connect to power
- **GCP Linux VMs**: Known issue — refer to the Tailscale docs for workaround

## Worked examples

| If the user wants to… | Fetch |
|---|---|
| Test how their app looks or behaves for users in other countries (localization, geo-routing, region-specific content) | https://tailscale.com/docs/use-cases/application-testing/geo-specific-testing |
| Protect their browsing on untrusted Wi-Fi by routing traffic through a device they own | https://tailscale.com/docs/solutions/secure-traffic-public-wifi-appletv |
