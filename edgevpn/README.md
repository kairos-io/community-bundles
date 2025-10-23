# EdgeVPN Bundle

The EdgeVPN bundle deploys [EdgeVPN](https://github.com/mudler/edgevpn) to create a mesh VPN network.

The bundle supports both systemd and openrc init systems, making it compatible with Alpine-based distributions.

## Configuration

To configure the bundle, use the `edgevpn` block:

```yaml
#cloud-config

# Specify the bundle to use
bundles:
  - targets:
      - run://quay.io/kairos/community-bundles:edgevpn_latest

# Specify edgevpn settings
edgevpn:
  token: "your-edgevpn-token-here"
```

The bundle will automatically detect the init system (systemd or openrc) and configure the service accordingly.
