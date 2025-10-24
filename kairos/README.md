# Kairos Bundle

The Kairos bundle deploys the [Kairos helm-charts](https://github.com/kairos-io/helm-charts). It installs the `kairos-crds` chart, and allows to enable [entangle-proxy](https://kairos.io/docs/reference/entangle/), [osbuilder](https://kairos.io/docs/advanced/build/), and [entangle](https://kairos.io/docs/reference/entangle/).

## Configuration

By default the bundle will install only the CRDs, components needs to be explicitly enabled:

```yaml
#cloud-config

# Specify the bundle to use
bundles:
  - targets:
      - run://quay.io/kairos/community-bundles:kairos_latest

# Specify kairos bundle setting
kairos:
  osbuilder:
    enable: true
    version: ... #optional
  entangle:
    enable: true
    version: ... #optional
  entangleProxy:
    enable: true
    version: ... #optional
```
