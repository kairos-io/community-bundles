
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

## Kubevirt

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

## Development

If you want to build and test a bundle, you can use earthly by running the following commands:

```
# build
earthly +build --BUNDLE=<bundle-name>
# test
earthly +test --BUNDLE=<bundle-name>
```
