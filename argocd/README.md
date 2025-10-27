# ArgoCD Bundle

The ArgoCD bundle deploys [ArgoCD](https://argo-cd.readthedocs.io/en/stable/).

## Configuration

To configure the bundle, use the `argocd` block:

```yaml
#cloud-config

# Specify the bundle to use
bundles:
  - targets:
      - run://quay.io/kairos/community-bundles:argocd_latest

# Specify argocd settings
argocd:
  values: 
    redis-ha:
      enabled: true
    controller:
      replicas: 1
    server:
      autoscaling:
        enabled: true
        minReplicas: 2
  version: 7.5.2
```
