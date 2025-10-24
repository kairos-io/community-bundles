# Longhorn Bundle

The longhorn bundle deploys [Longhorn](https://longhorn.io/docs/).

## Configuration

To configure the bundle, use the `longhorn` block:

```yaml
#cloud-config

# Specify the bundle to use
bundles:
  - targets:
      - run://quay.io/kairos/community-bundles:longhorn_latest

# Specify longhorn settings
longhorn:
  values:
    defaultSettings:
      backupstorePollInterval: 600
  version: 1.4.0
```

Note that specifying `values` and `version` are optional. Specifying `values` allows you to
[customize the Helm Chart](https://longhorn.io/docs/latest/advanced-resources/deploy/customizing-default-settings/#using-helm).
