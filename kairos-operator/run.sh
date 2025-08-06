#!/bin/bash

set -ex

# Check for k0s or k3s binary and set manifest directory accordingly
if command -v k0s >/dev/null 2>&1; then
    K0S_MANIFEST_DIR=${K0S_MANIFEST_DIR:-/var/lib/k0s/manifests/kairos-operator/}
    MANIFEST_DIR="${K0S_MANIFEST_DIR}"
elif command -v k3s >/dev/null 2>&1; then
    K3S_MANIFEST_DIR=${K3S_MANIFEST_DIR:-/var/lib/rancher/k3s/server/manifests/}
    MANIFEST_DIR="${K3S_MANIFEST_DIR}"
else
    echo "Neither k0s nor k3s binary found. Please ensure one is installed."
    exit 1
fi

getConfig() {
    local l="$1"
    key=$(kairos-agent config get "${l}" | tr -d '\n')
    if [ "$key" != "null" ]; then
     echo "${key}"
    fi 
    echo   
}

VERSION="v0.0.1"

templ() {
    local file="$3"
    local value="$2"
    local sentinel="$1"
    sed -i "s/@${sentinel}@/${value}/g" "${file}"
}

readConfig() {
    _version=$(getConfig kairos-operator.version)
    if [ "$_version" != "" ]; then
        VERSION=$_version
    fi
}

mkdir -p "${MANIFEST_DIR}"

readConfig

# Copy manifests, and template them
for FILE in assets/*; do 
  templ "VERSION" "${VERSION}" "${FILE}"
done;

cp -rf assets/* "${MANIFEST_DIR}" 