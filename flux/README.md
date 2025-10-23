# Flux Bundle

This installs [FluxCD](https://fluxcd.io/flux/cmd/flux_bootstrap/) and supports
automatically bootstrapping the cluster. Only one node will do the bootstrap.
It will time out after trying for 30 minutes and it requires `systemd`.

## Configuration

```yaml
#cloud-config

k3s:
  enabled: true

bundles:
  - targets:
      - run://quay.io/kairos/community-bundles:flux_latest

# Specify command-line arguments as keys under a key of `bitbucket_server`,
# `git`, `github` or `gitlab` for the provider to boostrap from. An example for
# `github` is shown below.
flux:
  env:
    # Override default $KUBECONFIG of /etc/rancher/k3s/k3s.yaml if needed
    # KUBECONFIG: /home/csagan/.kube/config
    GITHUB_TOKEN: abcde1234
  github:
    owner: csagan
    repository: fleet-infra
    path: clusters/cosmos
    components-extra: image-reflector-controller,image-automation-controller
```
