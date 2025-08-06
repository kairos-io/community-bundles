# Kairos Operator Bundle

This bundle deploys the [Kairos Operator](https://github.com/kairos-io/kairos-operator) to a k0s or k3s cluster.

## Configuration

The bundle can be configured using Kairos agent configuration:

```yaml
kairos-operator:
  version: "v0.0.1"  # Optional, defaults to v0.0.1
```

## Usage

The bundle will:

1. Generate the Kairos operator manifests at build time using `kubectl kustomize`
2. Template the version placeholders with the configured version
3. Automatically detect whether k0s or k3s is running and deploy to the appropriate manifest directory:
   - **k0s**: `/var/lib/k0s/manifests/kairos-operator/`
   - **k3s**: `/var/lib/rancher/k3s/server/manifests/`

## Features

- **Version templating**: The operator image version can be configured via Kairos agent config
- **Multi-distribution support**: Automatically detects and works with both k0s and k3s clusters
- **Build-time generation**: Manifests are generated during Docker build, not runtime

## Custom Resources

The Kairos operator provides two custom resources:

- **NodeOp**: For generic operations on Kubernetes nodes
- **NodeOpUpgrade**: For Kairos-specific node upgrades

See the [Kairos Operator documentation](https://github.com/kairos-io/kairos-operator) for more details on usage.

## Development

### Building the Bundle

To build and test the bundle locally:

```bash
./build.sh
```

This will build the image with version `v0.0.1` by default. You can override the version:

```bash
VERSION=v0.0.1-rc6 ./build.sh
```

### Current Version Issue

**Note**: The current `v0.0.1` tag in the Kairos operator repository still references release candidate image versions (`v0.0.1-rc6`). This is a repository issue that should be resolved by the maintainers. The bundle will use whatever versions are specified in the kustomization.yaml file at the specified tag. 