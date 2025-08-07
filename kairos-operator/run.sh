#!/bin/bash

set -ex

getConfig() {
    local l="$1"
    key=$(kairos-agent config get "${l}" | tr -d '\n')
    if [ "$key" != "null" ]; then
     echo "${key}"
    fi 
    echo   
}

# renovate: datasource=github-releases depName=kairos-io/kairos-operator
VERSION="0.0.1"

readConfig() {
    _version=$(getConfig kairos-operator.version)
    if [ "$_version" != "" ]; then
        VERSION=$_version
    fi
    _k0s=$(getConfig kairos-operator.k0s)
    _k3s=$(getConfig kairos-operator.k3s)
    _manifest_dir=$(getConfig kairos-operator.manifest_dir)

    if [ "$_manifest_dir" != "" ]; then
        MANIFEST_DIR=$_manifest_dir
    elif [ "$_k0s" == "true" ]; then
        MANIFEST_DIR=/var/lib/k0s/manifests/kairos-operator/
    elif [ "$_k3s" == "true" ]; then
        MANIFEST_DIR=/var/lib/rancher/k3s/server/manifests/
    elif command -v k0s >/dev/null 2>&1; then
        MANIFEST_DIR=/var/lib/k0s/manifests/kairos-operator/
    elif command -v k3s >/dev/null 2>&1; then
        MANIFEST_DIR=/var/lib/rancher/k3s/server/manifests/
    else
        echo "Could not determine manifest directory. Please set one of the following options:"
        echo "- kairos-operator.manifest_dir in the cloud-config."
        echo "- kairos-operator.k0s in the cloud-config."
        echo "- kairos-operator.k3s in the cloud-config."
        exit 1
    fi
}

mkdir -p "${MANIFEST_DIR}"

readConfig

cp -rf assets/* "${MANIFEST_DIR}"