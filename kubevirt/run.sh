#!/bin/bash

set -ex

K3S_MANIFEST_DIR=${K3S_MANIFEST_DIR:-/var/lib/rancher/k3s/server/manifests/}

getConfig() {
    local l=$1
    key=$(kairos-agent config get "${l}" | tr -d '\n')
    if [ "$key" != "null" ]; then
     echo "${key}"
    fi 
    echo   
}

KUBEVIRT_MANAGER="false"

templ() {
    local file="$3"
    local value="$2"
    local sentinel="$1"
    sed -i "s/@${sentinel}@/${value}/g" "${file}"
}

readConfig() {
    _manager=$(getConfig kubevirt.manager)
    if [ "$_manager" != "" ]; then
        KUBEVIRT_MANAGER=$_manager
    fi
}

mkdir -p "${K3S_MANIFEST_DIR}"

readConfig

# Copy manifests from kubevirt
cp -rf assets/* "${K3S_MANIFEST_DIR}"

if [ "$KUBEVIRT_MANAGER" == "true" ]; then
    cp -rf kubevirt-manager-manifests/* "${K3S_MANIFEST_DIR}"
fi
