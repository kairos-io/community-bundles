# community-bundles

Welcome to the community-bundles repository! This repository builds and pushes Kairos community bundles that can be consumed by Kairos core or derivative images (such as [provider-kairos](https://github.com/kairos-io/provider-kairos)) to extend Kairos configurations and settings, and to add cloud-config keywords.

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

## Development

If you want to build and test a bundle, you can use earthly by running the following commands:

```
# build
earthly +build --BUNDLE=<bundle-name>
# test
earthly +test --BUNDLE=<bundle-name>
```
