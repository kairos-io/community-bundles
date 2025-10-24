# Nginx Bundle

The Nginx bundle deploys [Ingress-Nginx-Controller](https://kubernetes.github.io/ingress-nginx/) in the cluster, available after boostrap.

## Configuration

The bundle does add a `nginx` block, that allow to set up the nginx version and helm chart [values](https://github.com/kubernetes/ingress-nginx/blob/main/charts/ingress-nginx/values.yaml) in the Kairos configuration file:

```yaml
#cloud-config

# Specify the bundle to use
bundles:
  - targets:
      - run://quay.io/kairos/community-bundles:nginx_latest

# Specify nginx settings
nginx:
  version: 4.7.3
```

```yaml
#cloud-config

# Specify the bundle to use
bundles:
  - targets:
      - run://quay.io/kairos/community-bundles:nginx_latest

# Specify nginx settings
nginx:
  values:
    commonLabels:
      myLabel: abc123
```

Note, you might want to disable the default Ingress-Controller of k3s, a full example can be:

```yaml
#cloud-config

hostname: kairoslab-{{ trunc 4 .MachineID }}
users:
  - name: kairos
    ssh_authorized_keys:
      # Add your github user here!
      - github:mudler

k3s:
  enabled: true
  args:
    - --disable=traefik

# Specify the bundle to use
bundles:
  - targets:
      - run://quay.io/kairos/community-bundles:nginx_latest

# Specify nginx settings
nginx:
  version: 4.7.3
```
