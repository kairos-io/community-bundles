#!/bin/bash

set -ex

K3S_MANIFEST_DIR=${K3S_MANIFEST_DIR:-/var/lib/rancher/k3s/server/manifests/}

VALUES="{}"
# renovate: depName=ingress-nginx repoUrl=https://kubernetes.github.io/ingress-nginx
VERSION="4.11.2"

templ() {
    local file="$3"
    local value="$2"
    local sentinel="$1"
    sed -i "s/@${sentinel}@/${value}/g" "${file}"
}

_version=$(kairos-agent config get "nginx.version" | tr -d '\n')
if [ "$_version" != "null" ]; then
    VERSION=$_version
fi
_values=$(kairos-agent config get "nginx.values | @json" | tr -d '\n')
# Remove the quotes wrapping the value.
_values=${_values:1:${#_values}-2}
if [ "$_values" != "null" ]; then
    VALUES=$_values
fi

templ "VERSION" "${VERSION}" "assets/ingress-nginx.yaml"
templ "VALUES" "${VALUES}" "assets/ingress-nginx.yaml"

mkdir -p "${K3S_MANIFEST_DIR}"
cp -rf assets/* "${K3S_MANIFEST_DIR}"
