# Multus Bundle

The Multus bundle deploys [Multus CNI](https://github.com/k8snetworkplumbingwg/multus-cni), along with specified [CNI plugins](https://www.cni.dev/plugins/current/).

The only created resources are the ClusterRole and the associated ClusterRoleBinding. Instead of creating a service account, it sets up a _normal user_ using an [X509 client certificate](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#x509-client-certs). This client certificate has a validity of 3650 days by default which can be overwritten by the configuration.

## Configuration

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
  # considered "global" and allow their NetworkAttachmentDefinitions to be
  # referred to by pods in other namespaces. May also be a coma-delimited list.
  global_namespaces: []

  # Full path to the CNI configuration wrapped by Multus. If left unset, scan
  # the multus.cni_conf_dir directory, sort the filenames alphabetically and
  # use the first file result.
  primary_config: ~
```
