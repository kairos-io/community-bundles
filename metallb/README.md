# MetalLB Bundle

The MetalLB bundle deploys [MetalLB](https://metallb.universe.tf/installation/) in the cluster, available after boostrap.

## Configuration

The bundle does add a `metallb` block, that allow to set up the MetalLB version and the address pool in the Kairos configuration file:

```yaml
#cloud-config

# Specify the bundle to use
bundles:
  - targets:
      - run://quay.io/kairos/community-bundles:metallb_latest

# Specify metallb settings
metallb:
  version: 0.13.7
  address_pool: 192.168.1.10-192.168.1.20
```

Note, you might want to disable the default LoadBalancer of k3s, a full example can be:

```yaml
#cloud-config

hostname: kairoslab-{{ trunc 4 .MachineID }}
users:
  - name: kairos
    ssh_authorized_keys:
      # Add your github user here!
      - github:mudler

k3s:
  enabled: true
  args:
    - --disable=servicelb

# Specify the bundle to use
bundles:
  - targets:
      - run://quay.io/kairos/community-bundles:metallb_latest

# Specify metallb settings
metallb:
  version: 0.13.7
  address_pool: 192.168.1.10-192.168.1.20
```
