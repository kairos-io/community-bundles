# System upgrade controller Bundle

The System upgrade controller bundle deploys [System upgrade controller](https://github.com/rancher/system-upgrade-controller).

## Configuration

The bundle does add a `suc` block, that allow to change the version:

```yaml
#cloud-config

# Specify the bundle to use
bundles:
  - targets:
      - run://quay.io/kairos/community-bundles:system-upgrade-controller_latest

# Specify system-upgrade-controller settings
suc:
  version: v0.10.0
```
