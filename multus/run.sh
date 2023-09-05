#!/bin/bash

set -ex

K3S_MANIFEST_DIR=${K3S_MANIFEST_DIR:-/var/lib/rancher/k3s/server/manifests}
CNI_BIN_DIR=/opt/cni/bin
MULTUS_BIN_DIR=/var/lib/rancher/k3s/data/current/bin
CNI_CONF_DIR=/var/lib/rancher/k3s/agent/etc/cni/net.d
CA_PATH=/var/lib/rancher/k3s/server/tls

getConfig() {
    local l=$1
    key=$(kairos-agent config get "${l}")
    if [[ $key != "null" ]]; then
     echo "${key}"
    fi
    echo
}

CNI_PLUGINS=
CRT_VALIDITY=3650
NAMESPACE_ISOLATION=false
GLOBAL_NAMESPACES=
PRIMARY_CONFIG=

readConfig() {
    _cni_plugins=$(getConfig multus.cni_plugins[]?)
    if [[ $_cni_plugins != "" ]]; then
        CNI_PLUGINS=$_cni_plugins
    fi

    _crt_validity=$(getConfig multus.crt_validity)
    if [[ $_crt_validity != "" ]]; then
        CRT_VALIDITY=$_crt_validity
    fi

    _namespace_isolation=$(getConfig multus.namespace_isolation)
    if [[ $_namespace_isolation != "" ]]; then
        NAMESPACE_ISOLATION=$_namespace_isolation
    fi

    _global_namespaces=$(getConfig multus.global_namespaces[]?)
    if [[ $_global_namespaces != "" ]]; then
        GLOBAL_NAMESPACES=${_global_namespaces//[[:space:]]/,}
    fi

    _primary_config=$(getConfig multus.primary_config)
    if [[ $_primary_config != "" ]]; then
        PRIMARY_CONFIG=$_primary_config
    else
        for config in "${CNI_CONF_DIR}"/*.conflist; do
            if [[ $config != "${CNI_CONF_DIR}/00-multus.conflist" ]]; then
                PRIMARY_CONFIG=$config
                break;
            fi
        done
    fi
}

createDirectories() {
    mkdir -p \
        "${CNI_BIN_DIR}" \
        "${MULTUS_BIN_DIR}" \
        "${K3S_MANIFEST_DIR}" \
        "${CNI_CONF_DIR}/multus.d"
}

install() {
    cp multus "${MULTUS_BIN_DIR}"
}

installPlugins() {
    for plugin in $CNI_PLUGINS; do
        cp "plugins/${plugin}" "${CNI_BIN_DIR}"
    done
}

createManifests() {
    cp manifests.yaml "${K3S_MANIFEST_DIR}/multus.yaml"
}

createKubeConfig() {
    openssl ecparam -name prime256v1 -genkey -noout -out multus.key
    openssl req -new -key multus.key -out multus.csr -subj /CN=multus
    openssl x509 -req \
        -in multus.csr \
        -CA "${CA_PATH}/client-ca.crt" \
        -CAkey "${CA_PATH}/client-ca.key" \
        -CAcreateserial \
        -out multus.crt \
        -days "${CRT_VALIDITY}"

    cat > "${CNI_CONF_DIR}/multus.d/multus.kubeconfig" <<YAML
# Kubeconfig file for Multus CNI plugin.
apiVersion: v1
kind: Config
clusters:
- name: local
  cluster:
    server: https://127.0.0.1:6443
    certificate-authority-data: "$(base64 -w0 "${CA_PATH}/server-ca.crt")"
users:
- name: multus
  user:
    client-certificate-data: "$(base64 -w0 multus.crt)"
    client-key-data: "$(base64 -w0 multus.key)"
contexts:
- name: multus-context
  context:
    cluster: local
    user: multus
current-context: multus-context
YAML

    chmod 600 "${CNI_CONF_DIR}/multus.d/multus.kubeconfig"
}

createConfig() {
    jq < "${PRIMARY_CONFIG}" > "${CNI_CONF_DIR}/00-multus.conflist" \
        --arg namespaceIsolation "${NAMESPACE_ISOLATION}" \
        --arg globalNamespaces "${GLOBAL_NAMESPACES}" \
        --arg kubeconfig "${CNI_CONF_DIR}/multus.d/multus.kubeconfig" \
        '
            {
                cniVersion: .cniVersion,
                name: "multus-cni-network",
                plugins: [{
                    type: "multus",
                    capabilities: [.plugins[].capabilities] | add,
                    namespaceIsolation: ($namespaceIsolation == "true"),
                    globalNamespaces: $globalNamespaces,
                    kubeconfig: $kubeconfig,
                    delegates: [.]
                }]
            }
        '

    chmod 600 "${CNI_CONF_DIR}/00-multus.conflist"
}

readConfig
createDirectories
install
installPlugins
createManifests
createKubeConfig
createConfig
