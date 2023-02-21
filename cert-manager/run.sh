#!/bin/bash

set -ex

K3S_MANIFEST_DIR=${K3S_MANIFEST_DIR:-/var/lib/rancher/k3s/server/manifests/}

getConfig() {
    local l="$1"
    key=$(kairos-agent config get "${l}" | tr -d '\n')
    if [ "$key" != "null" ]; then
     echo "${key}"
    fi 
    echo   
}

VERSION="v1.11.0"

templ() {
    local file="$3"
    local value="$2"
    local sentinel="$1"
    sed -i "s/@${sentinel}@/${value}/g" "${file}"
}

readConfig() {
    _version="$(getConfig 'certManager.version')"
    if [ "$_version" != "" ]; then
        VERSION=$_version
    fi
}

mkdir -p "${K3S_MANIFEST_DIR}"

readConfig

cp -rf "assets/cert-manager-${VERSION}.yaml" "${K3S_MANIFEST_DIR}/cert-manager.yaml"
