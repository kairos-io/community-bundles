#!/bin/bash

set -ex

K3S_MANIFEST_DIR=${K3S_MANIFEST_DIR:-/var/lib/rancher/k3s/server/manifests/}

VERSION="3.4.2"

templ() {
    local file="$3"
    local value="$2"
    local sentinel="$1"
    sed -i "s/@${sentinel}@/${value}/g" "${file}"
}

mkdir -p "${K3S_MANIFEST_DIR}"

# Set the service type
serviceType=$(kairos-agent config get localai.serviceType | tr -d '\n')
if [[ -z "$serviceType" ]]; then
  serviceType="ClusterIP"
fi
templ "SERVICETYPE" "${serviceType}" assets/localai.yaml

# Set the version of the helm chart
for FILE in assets/*; do 
  templ "VERSION" "${VERSION}" "${FILE}"
done;

cp -rf assets/* "${K3S_MANIFEST_DIR}"
