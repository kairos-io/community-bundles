# Kubevirt Bundle

The Kubevirt bundle deploys [Kubevirt](https://github.com/kubevirt/kubevirt) and optionally [kubevirt-manager](https://kubevirt-manager.io/)

## Configuration

The bundle does add a `kubevirt` block, that allow to enable `kubevirt-manager`:

```yaml
#cloud-config

# Specify the bundle to use
bundles:
  - targets:
      - run://quay.io/kairos/community-bundles:kubevirt_latest

# Specify kubevirt settings
kubevirt:
  manager: true
```
