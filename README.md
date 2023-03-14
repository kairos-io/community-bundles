
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

- [Usage](#usage)
- [Bundles](#bundles)
  - [Calico](#calico)
  - [Cert-Manager](#cert-manager)
  - [Kairos](#kairos)
  - [Kyverno](#kyverno)
  - [Kubevirt](#kubevirt)
  - [Longhorn](#longhorn)
  - [MetalLB](#metallb)
  - [System Upgrade Controller](#system-upgrade-controller)
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

Note that specifying `values` and `version` are optional.  Specifying `values` allows you to
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
  values:
    ....
  version: ...
```

Note that specifying `values` and `version` are optional.  Specifying `values` allows you to
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

Note that specifying `values` and `version` are optional.  Specifying `values` allows you to
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
  enable: true
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

## Development

If you want to build and test a bundle, you can use earthly by running the following commands:

```
# build
./earthly.sh +build --BUNDLE=<bundle-name>
# test
./earthly.sh +test --BUNDLE=<bundle-name>
```

We also provide a version of the `earthly.sh` script for Windows (`eartly.ps1`).
