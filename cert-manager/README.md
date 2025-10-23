# Cert-manager Bundle

The cert-manager bundle deploys [cert-manager](https://cert-manager.io/docs/installation/).

## Configuration

The bundle does add a `certManager` block, that allow to change the version (currently only available `v1.11.0`):

```yaml
#cloud-config

# Specify the bundle to use
bundles:
  - targets:
      - run://quay.io/kairos/community-bundles:cert-manager_latest

# Specify cert-manager settings
certManager:
  version: v1.11.0
```
