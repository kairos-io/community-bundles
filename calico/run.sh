#!/bin/bash

set -ex

K3S_MANIFEST_DIR=${K3S_MANIFEST_DIR:-/var/lib/rancher/k3s/server/manifests/}

VALUES="{}"
# renovate: depName=tigera-operator repoUrl=https://docs.tigera.io/calico/charts
VERSION="v3.30.3"

templ() {
    local file="$3"
    local value="$2"
    local sentinel="$1"
    sed -i "s/@${sentinel}@/${value}/g" "${file}"
}

_version=$(kairos-agent config get "calico.version" | tr -d '\n')
if [ "$_version" != "null" ]; then
    VERSION=$_version
fi
_values=$(kairos-agent config get "calico.values | @json" | tr -d '\n')
# Remove the quotes wrapping the value.
_values=${_values:1:${#_values}-2}
if [ "$_values" != "null" ]; then
    VALUES=$_values
fi

# Copy manifests, and template them
for FILE in assets/*; do
  templ "VALUES" "${VALUES}" "${FILE}"
  templ "VERSION" "${VERSION}" "${FILE}"
done;

mkdir -p "${K3S_MANIFEST_DIR}"
cp -rf assets/* "${K3S_MANIFEST_DIR}"
