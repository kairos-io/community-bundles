# Kyverno Bundle

The Kyverno bundle deploys [Kyverno](https://kyverno.io/docs/introduction/).

## Configuration

To configure the bundle, use the `kyverno` block:

```yaml
#cloud-config

# Specify the bundle to use
bundles:
  - targets:
      - run://quay.io/kairos/community-bundles:kyverno_latest

# Specify kyverno settings
kyverno:
  values: ....
  version: ...
```

Note that specifying `values` and `version` are optional. Specifying `values` allows you to
[customize the Helm Chart](https://github.com/kyverno/kyverno/blob/main/charts/kyverno/values.yaml).
