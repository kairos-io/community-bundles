# SpinKube Bundle

> **WARNING**: This will not work with Kairos distributions that don't use `systemd` (i.e. Alpine).

The SpinKube bundle deploys [SpinKube](https://spinkube.dev) to a running k3s cluster.

## Configuration

The bundle has a `spinkube` block that allows you to install `cert-manager`, which is required by SpinKube:

```yaml
bundles:
    - targets:
        - run://quay.io/kairos/community-bundles:spinkube_latest

spinkube:
    installCertManager: true
```

If you don't want to use the bundle's `cert-manager` installation, be sure to check [SpinKube](https://www.spinkube.dev/docs/install/)'s documentation for which version of `cert-manager` to use.
