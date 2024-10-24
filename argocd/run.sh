#!/bin/bash

set -ex

K3S_MANIFEST_DIR=${K3S_MANIFEST_DIR:-/var/lib/rancher/k3s/server/manifests/}
BIN=/usr/local/bin/

getConfig() {
    local key=$1
    _value=$(kairos-agent config get "${key} | @json" | tr -d '\n')
    # Remove the quotes wrapping the value.
    _value=${_value:1:${#_value}-2}
    if [ "${_value}" != "null" ]; then
     echo "${_value}"
    fi 
    echo   
}

VALUES="{}"
VERSION="7.5.2" # Chart Version

templ() {
    local file="$3"
    local value=$2
    local sentinel=$1
    sed -i "s/@${sentinel}@/${value}/g" "${file}"
}

readConfig() {
    _values=$(getConfig argocd.values)
    if [ "$_values" != "" ]; then
        VALUES=$_values
    fi
    _version=$(getConfig argocd.version)
    if [ "$_version" != "" ]; then
        VERSION=$_version
    fi
}

mkdir -p "${K3S_MANIFEST_DIR}"
mkdir -p $BIN

readConfig

# Copy manifests, and template them
for FILE in assets/*; do 
  templ "VALUES" "${VALUES}" "${FILE}"
  templ "VERSION" "${VERSION}" "${FILE}"
done;

# get system arch
ARCH=$(uname -m) 

# Default to arm64 because community bundle don't support arm container so uname will always returns x86_64 
SYSTEM_ARCH="arm64"

if [ "$ARCH" == "x86_64" ]; then
    SYSTEM_ARCH="amd64"
fi

cp -rf assets/* "${K3S_MANIFEST_DIR}"
cp  argocd-linux-"$SYSTEM_ARCH" $BIN/argocd
sudo chmod +x $BIN/argocd
