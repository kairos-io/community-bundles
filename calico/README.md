# Calico Bundle

The calico bundle deploys [Project Calico](https://docs.tigera.io/calico/latest/about/).

## Configuration

To configure the bundle, use the `calico` block:

```yaml
#cloud-config

# Specify the bundle to use
bundles:
  - targets:
      - run://quay.io/kairos/community-bundles:calico_latest

# Specify calico settings
calico:
  values:
    installation:
      cni:
        type: Calico
      calicoNetwork:
        bgp: Disabled
      ipPools:
        - cidr: 10.244.0.0/16
          encapsulation: VXLAN
  version: 3.25.0
```

Note that specifying `values` and `version` are optional. Specifying `values` allows you to
[customize the Helm Chart](https://docs.tigera.io/calico/latest/getting-started/kubernetes/helm#customize-the-helm-chart).
