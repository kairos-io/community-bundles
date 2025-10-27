# K9s Bundle

The K9s bundle installs [K9s](https://k9scli.io/), a terminal-based UI for managing Kubernetes clusters.

This bundle installs the k9s binary to `/usr/local/bin/k9s`, making it available system-wide. No additional configuration is required.

## Usage

```yaml
#cloud-config

# Specify the bundle to use
bundles:
  - targets:
      - run://quay.io/kairos/community-bundles:k9s_latest
```

After installation, you can run `k9s` from the command line to manage your Kubernetes cluster.
