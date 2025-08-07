# Kairos Operator Bundle

This bundle deploys the [Kairos Operator](https://github.com/kairos-io/kairos-operator) to a k0s or k3s cluster.

## Configuration

The bundle can be configured using Kairos agent configuration:

```yaml
k0s:
  enabled: true # if k0s is enabled or binary is found in the system, it will install under /var/lib/k0s/manifests/kairos-operator/kairos-operator.yaml

k3s:
  enabled: true # if k3s is enabled or binery is found in the system, it will install under /var/lib/rancher/k3s/server/manifests/

kairosOperator:
  manifest_dir: "/custom/path" # (optional) overrides the previous defaults
```

## Usage

The bundle will:

1. Generate the Kairos operator manifests at build time using `kubectl kustomize`
2. Automatically detect whether k0s or k3s is running and deploy to the appropriate manifest directory:
   - **k0s**: `/var/lib/k0s/manifests/kairos-operator/`
   - **k3s**: `/var/lib/rancher/k3s/server/manifests/`
3. Copy the generated manifests to the detected directory

## Features

- **Multi-distribution support**: Automatically detects and works with both k0s and k3s clusters
- **Custom manifest directory**: Can be configured to use a custom directory via `manifest_dir`
- **Build-time generation**: Manifests are generated during Docker build, not runtime
- **Version management**: Uses version `0.0.2` by default (configurable via Dockerfile)

## Configuration Options

### Automatic Detection
The bundle automatically detects the Kubernetes distribution by:
1. Checking for `k0s` or `k3s` commands in PATH
2. Using configuration flags if automatic detection fails

### Manual Configuration
You can override the automatic detection by setting configuration options:

```yaml
# Force k0s detection
kairosOperator:
  k0s: true

# Force k3s detection  
kairosOperator:
  k3s: true

# Use custom manifest directory
kairosOperator:
  manifest_dir: "/var/lib/custom/manifests/"
```

See the [Kairos Operator documentation](https://github.com/kairos-io/kairos-operator) for more details on usage.

## Development

### Building the Bundle

The bundle is built using Docker. The version can be configured by modifying the `VERSION` environment variable in the Dockerfile:

```dockerfile
ENV VERSION=0.0.2
```

### Current Version

The bundle currently uses version `0.0.2` of the Kairos operator. This version is managed via Renovate and can be updated by modifying the Dockerfile. 