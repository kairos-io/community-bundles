<h1 align="center">
  <br>
     <img width="184" alt="kairos-white-column 5bc2fe34" src="https://user-images.githubusercontent.com/2420543/193010398-72d4ba6e-7efe-4c2e-b7ba-d3a826a55b7d.png">
    <br>
<br>
</h1>

<h3 align="center">Kairos Community Bundles</h3>

<hr>

Welcome to the community-bundles repository! This repository builds and pushes Kairos community bundles that can be consumed by Kairos core or derivative images (such as [provider-kairos](https://github.com/kairos-io/provider-kairos) ) to extend Kairos configurations and settings, and to add cloud-config keywords.

Please note that these community bundles are not officially supported and are provided on a best-effort basis by the community.

## Table of Contents

- [Table of Contents](#table-of-contents)
- [Usage](#usage)
- [Bundles](#bundles)
  - [Calico](#calico)
  - [Cert-manager](#cert-manager)
  - [Flux](#flux)
  - [Kairos](#kairos)
  - [Kyverno](#kyverno)
  - [Kubevirt](#kubevirt)
  - [Longhorn](#longhorn)
  - [MetalLB](#metallb)
  - [Multus](#multus)
  - [Nginx](#nginx)
  - [SpinKube](#spinkube)
  - [System upgrade controller](#system-upgrade-controller)
  - [ArgoCD](#argocd)
- [Development](#development)

## Usage

To use a community bundle, you can load it with the bundles block in the Kairos configuration file, like this:

```yaml
bundles:
  - targets:
      - run://quay.io/kairos/community-bundles:<bundle-name>
```

Here is an example of how you might use a community bundle in a Kairos core image:

```yaml
#cloud-config
install:
  device: "auto"
  auto: true
  reboot: true
  image: "docker:quay.io/kairos/kairos-opensuse:v1.4.0-k3sv1.26.0-k3s1"

users:
  - name: "kairos"
    passwd: "kairos"
    ssh_authorized_keys:
      - ...

bundles:
  - targets:
      - run://quay.io/kairos/community-bundles:kubevirt

k3s:
  enabled: true
```

## Bundles

### Calico

The calico bundle deploys [Project Calico](https://docs.tigera.io/calico/latest/about/).

To configure the bundle, use the `calico` block:

```yaml
#cloud-config

# Specify the bundle to use
bundles:
  - targets:
      - run://quay.io/kairos/community-bundles:calico_latest

# Specify calico settings
calico:
  values:
    installation:
      cni:
        type: Calico
      calicoNetwork:
        bgp: Disabled
      ipPools:
        - cidr: 10.244.0.0/16
          encapsulation: VXLAN
  version: 3.25.0
```

Note that specifying `values` and `version` are optional. Specifying `values` allows you to
[customize the Helm Chart](https://docs.tigera.io/calico/latest/getting-started/kubernetes/helm#customize-the-helm-chart).

### Cert-manager

The cert-manager bundle deploys [cert-manager](https://cert-manager.io/docs/installation/).

The bundle does add a `certManager` block, that allow to change the version (currently only available `v1.11.0`):

```yaml
#cloud-config

# Specify the bundle to use
bundles:
  - targets:
      - run://quay.io/kairos/community-bundles:cert-manager_latest

# Specify cert-manager settings
certManager:
  version: v1.11.0
```

### Flux

This installs [FluxCD](https://fluxcd.io/flux/cmd/flux_bootstrap/) and supports
automatically bootstrapping the cluster. Only one node will do the bootstrap.
It will time out after trying for 30 minutes and it requires `systemd`.

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

### Kairos

The Kairos bundle deploys the [Kairos helm-charts](https://github.com/kairos-io/helm-charts). It installs the `kairos-crds` chart, and allows to enable [entangle-proxy](https://kairos.io/docs/reference/entangle/), [osbuilder](https://kairos.io/docs/advanced/build/), and [entangle](https://kairos.io/docs/reference/entangle/).

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

### Kyverno

The Kyverno bundle deploys [Kyverno](https://kyverno.io/docs/introduction/).

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

### Kubevirt

The Kubevirt bundle deploys [Kubevirt](https://github.com/kubevirt/kubevirt) and optionally [kubevirt-manager](https://kubevirt-manager.io/)

The bundle does add a `kubevirt` block, that allow to enable `kubevirt-manager`:

```yaml
#cloud-config

# Specify the bundle to use
bundles:
  - targets:
      - run://quay.io/kairos/community-bundles:kubevirt_latest

# Specify kubevirt settings
kubevirt:
  manager: true
```

### Longhorn

The longhorn bundle deploys [Longhorn](https://longhorn.io/docs/).

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

### MetalLB

The MetalLB bundle deploys [MetalLB](https://metallb.universe.tf/installation/) in the cluster, available after boostrap.

The bundle does add a `metallb` block, that allow to set up the MetalLB version and the address pool in the Kairos configuration file:

```yaml
#cloud-config

# Specify the bundle to use
bundles:
  - targets:
      - run://quay.io/kairos/community-bundles:metallb_latest

# Specify metallb settings
metallb:
  version: 0.13.7
  address_pool: 192.168.1.10-192.168.1.20
```

Note, you might want to disable the default LoadBalancer of k3s, a full example can be:

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
    - --disable=servicelb

# Specify the bundle to use
bundles:
  - targets:
      - run://quay.io/kairos/community-bundles:metallb_latest

# Specify metallb settings
metallb:
  version: 0.13.7
  address_pool: 192.168.1.10-192.168.1.20
```

### Multus

The Multus bundle deploys [Multus CNI](https://github.com/k8snetworkplumbingwg/multus-cni), along with specified [CNI plugins](https://www.cni.dev/plugins/current/).

The only created resources are the ClusterRole and the associated ClusterRoleBinding. Instead of creating a service account, it sets up a _normal user_ using an [X509 client certificate](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#x509-client-certs). This client certificate has a validity of 3650 days by default which can be overwritten by the configuration.

To configure the bundle, use the `multus` block:

```yaml
# Specify the bundle to use
bundles:
  - targets:
      - run://quay.io/kairos/community-bundles:multus_latest

# Specify multus settings. Here are the defaults:
multus:
  # List of additional CNI plugins to install. May also be a
  # whitelist-delimited list.
  # See https://www.cni.dev/plugins/current/ for available plugins.
  cni_plugins: []

  # Full path to the directory the plugins will be installed.
  cni_bin_dir: /opt/cni/bin

  # Full path to the directory where multus will be installed.
  multus_bin_dir: /var/lib/rancher/k3s/data/current/bin

  # Full path to the directory where the configuration files will be written.
  cni_conf_dir: /var/lib/rancher/k3s/agent/etc/cni/net.d

  # Full path to the directory containing certificate authority (CA) files.
  ca_path: /var/lib/rancher/k3s/server/tls

  # Duration (in days) during which the generated certificate will be valid
  # for.
  crt_validity: 3650

  # URL of the Kubernetes API
  cluster_server: https://127.0.0.1:6443

  # Whether or not to isolate the NetworkAttachmentDefinition resources so that
  # the pods referring to them must be in the same namespace.
  namespace_isolation: false

  # When namespace isolation is enabled, list of namespaces that are to be
  # considered “global” and allow their NetworkAttachmentDefinitions to be
  # referred to by pods in other namespaces. May also be a coma-delimited list.
  global_namespaces: []

  # Full path to the CNI configuration wrapped by Multus. If left unset, scan
  # the multus.cni_conf_dir directory, sort the filenames alphabetically and
  # use the first file result.
  primary_config: ~
```

### Nginx

The Nginx bundle deploys [Ingress-Nginx-Controller](https://kubernetes.github.io/ingress-nginx/) in the cluster, available after boostrap.

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

### SpinKube

> **WARNING**: This will not work with Kairos distributions that don't use `systemd` (i.e. Alpine).

The SpinKube bundle deploys [SpinKube](https://spinkube.dev) to a running k3s cluster.

The bundle has a `spinkube` block that allows you to install `cert-manager`, which is required by SpinKube:

```yaml
bundles:
    - targets:
        - run://quay.io/kairos/community-bundles:spinkube_latest

spinkube:
    installCertManager: true
```

If you don't want to use the bundle's `cert-manager` installation, be sure to check [SpinKube](https://www.spinkube.dev/docs/install/)'s documentation for which version of `cert-manager` to use.

### System upgrade controller

The System upgrade controller bundle deploys [System upgrade controller](https://github.com/rancher/system-upgrade-controller).

The bundle does add a `suc` block, that allow to change the version:

```yaml
#cloud-config

# Specify the bundle to use
bundles:
  - targets:
      - run://quay.io/kairos/community-bundles:system-upgrade-controller_latest

# Specify system-upgrade-controller settings
suc:
  version: v0.10.0
```

### ArgoCD

The ArgoCD bundle deploys [ArgoCD](https://argo-cd.readthedocs.io/en/stable/).

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

## Development

If you want to build and test a bundle, you can use earthly by running the following commands:

```
# build
./earthly.sh +build --BUNDLE=<bundle-name>
# test
./earthly.sh +test --BUNDLE=<bundle-name>
```

We also provide a version of the `earthly.sh` script for Windows (`earthly.ps1`).
