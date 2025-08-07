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
VERSION="0.0.2"

readConfig() {
    _version=$(getConfig kairosOperator.version)
    if [ "$_version" != "" ]; then
        VERSION=$_version
    fi
    _k0s=$(getConfig kairosOperator.k0s)
    _k3s=$(getConfig kairosOperator.k3s)
    _manifest_dir=$(getConfig kairosOperator.manifest_dir)

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
        echo "- kairosOperator.manifest_dir in the cloud-config."
        echo "- kairosOperator.k0s in the cloud-config."
        echo "- kairosOperator.k3s in the cloud-config."
        exit 1
    fi
}

readConfig

mkdir -p "${MANIFEST_DIR}"
cp -rf assets/* "${MANIFEST_DIR}"