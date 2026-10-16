# Subnet Routers

Subnet routers act as gateways between your tailnet and networks where devices can't or don't run the Tailscale client. They let tailnet devices reach things like printers, IoT devices, cloud-managed databases (RDS, Cloud SQL), and entire VPCs — without installing Tailscale on every endpoint.

Devices behind subnet routers don't count toward your plan's device limit.

## Setup

### 1. Install Tailscale on the subnet router device

The device must sit on the network you want to expose. Install Tailscale using the standard method for the platform.

### 2. Enable IP forwarding (Linux)

```bash
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
sudo sysctl -p /etc/sysctl.d/99-tailscale.conf
```

If using `firewalld`:
```bash
firewall-cmd --permanent --add-masquerade
```

macOS handles IP forwarding automatically when advertising routes.

### 3. Advertise subnet routes

```bash
# Linux / macOS CLI
sudo tailscale set --advertise-routes=192.168.1.0/24,10.0.0.0/16

# Windows PowerShell
tailscale set --advertise-routes=192.168.1.0/24,10.0.0.0/16
```

Both IPv4 and IPv6 subnets are supported (except on Apple TV, which is IPv4 only).

**Android**: Open the Tailscale app > Settings > Subnet routing > Add route > enter CIDR.

### 4. Approve routes in admin console

1. Go to the **Machines** page
2. Find the device with the **Subnets** badge
3. Select it > **Subnets** section > **Edit** > approve the routes > **Save**

Skip this step if `autoApprovers` are configured in your tailnet policy file.

### 5. Add access rules

If you've modified the default access control policy, make sure your grants or ACLs allow traffic to the advertised subnets:

```json
{
  "groups": {
    "group:dev": ["alice@example.com", "bob@example.com"]
  },
  "grants": [
    {
      "src": ["group:dev"],
      "dst": ["192.168.1.0/24"],
      "ip": ["*:*"]
    }
  ]
}
```

### 6. Accept routes on client devices

Most platforms (macOS, Windows, iOS, Android) accept routes automatically. **Linux clients** need:

```bash
sudo tailscale set --accept-routes
```

### 7. Verify

```bash
# On the subnet router
tailscale ip -4

# From a client, ping the subnet router's Tailscale IP
ping <tailscale-ip>

# Then ping a device behind the subnet
ping 192.168.1.100
```

## Advanced features

### High availability

Run two subnet routers advertising the same routes for failover. If one goes offline, traffic automatically routes through the other. refer to Tailscale's high availability documentation for setup details.

### Overlapping routes

Multiple subnet routers can advertise overlapping routes with different prefix lengths. Tailscale uses longest prefix matching (LPM):

- Router A advertises `10.0.0.0/16`
- Router B advertises `10.0.0.0/24`
- Traffic to `10.0.0.5` goes through Router B (more specific match)
- Traffic to `10.0.1.5` goes through Router A

**Important**: Tailscale does not fall back to a less-specific route if the more-specific router goes offline. To avoid this, have all routers advertise both the broad and specific prefixes.

### Disable SNAT

By default, traffic from tailnet devices appears to come from the subnet router's IP (SNAT/masquerading). To preserve original source IPs (Linux only):

```bash
tailscale up --snat-subnet-routes=false
```

When SNAT is disabled, you must configure return routes on devices behind the subnet so they know how to route `100.64.0.0/10` traffic back through the subnet router.

### DNS for subnet resources

To resolve names for devices behind a subnet, configure split DNS in the admin console (**DNS** page). This lets your tailnet use an internal DNS server on the advertised subnet.

## Subnet routers vs. exit nodes

| | Subnet router | Exit node |
|---|---|---|
| **Purpose** | Access specific private subnets | Route all internet traffic |
| **Traffic** | Only traffic to advertised CIDRs | All non-Tailscale traffic |
| **Use case** | Reach printers, databases, VPCs | Secure public browsing, geo-access |

## Worked examples

| If the user wants to… | Fetch |
|---|---|
| Reach a printer, camera, IoT device, or whole home/office subnet that can't run Tailscale itself | https://tailscale.com/docs/use-cases/personal-or-at-home-use/access-devices-without-tailscale |
