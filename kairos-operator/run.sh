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

readConfig() {
    _k0s=$(getConfig k0s.enabled)
    _k3s=$(getConfig k3s.enabled)
    _manifest_dir=$(getConfig kairosOperator.manifest_dir)

    if [ "$_manifest_dir" != "" ]; then
        MANIFEST_DIR=$_manifest_dir
    elif [ "$_k0s" == "true" ] || command -v k0s >/dev/null 2>&1; then
        echo "k0s detected"
        MANIFEST_DIR=/var/lib/k0s/manifests/kairos-operator/
    elif [ "$_k3s" == "true" ] || command -v k3s >/dev/null 2>&1; then
        echo "k3s detected"
        MANIFEST_DIR=/var/lib/rancher/k3s/server/manifests/
    else
        echo "Could not determine manifest directory. Please set one of the following options:"
        echo "- k0s.enabled in the cloud-config."
        echo "- k3s.enabled in the cloud-config."
        echo "- kairosOperator.manifest_dir in the cloud-config."
        exit 1
    fi
}

readConfig

mkdir -p "${MANIFEST_DIR}"
cp -rf assets/* "${MANIFEST_DIR}"