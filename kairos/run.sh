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

# renovate: depName=entangle repoUrl=https://kairos-io.github.io/helm-charts
ENTANGLE_VERSION="0.2.2"
ENTANGLE_ENABLE=""
# renovate: depName=entangle-proxy repoUrl=https://kairos-io.github.io/helm-charts
ENTANGLEPROXY_VERSION="0.0.5"
ENTANGLEPROXY_ENABLE=""
# renovate: depName=osbuilder repoUrl=https://kairos-io.github.io/helm-charts
OSBUILDER_VERSION="0.5.5"
OSBUILDER_ENABLE=""

CRDS_VERSION="0.0.13"

templ() {
    local file="$3"
    local value="$2"
    local sentinel="$1"
    sed -i "s/@${sentinel}@/${value}/g" "${file}"
}

readConfig() {
    _version=$(getConfig kairos.crds.version)
    if [ "$_version" != "" ]; then
        CRDS_VERSION=$_version
    fi
    _enable=$(getConfig kairos.entangle.enable)
    if [ "$_enable" != "" ]; then
        ENTANGLE_ENABLE=$_enable
    fi
    _version=$(getConfig kairos.entangle.version)
    if [ "$_version" != "" ]; then
        ENTANGLE_VERSION=$_version
    fi
    _enable=$(getConfig kairos.entangleProxy.enable)
    if [ "$_enable" != "" ]; then
        ENTANGLEPROXY_ENABLE=$_enable
    fi
    _version=$(getConfig kairos.entangleProxy.version)
    if [ "$_version" != "" ]; then
        ENTANGLEPROXY_VERSION=$_version
    fi
    _enable=$(getConfig kairos.osbuilder.enable)
    if [ "$_enable" != "" ]; then
        OSBUILDER_ENABLE=$_enable
    fi
    _version=$(getConfig kairos.osbuilder.version)
    if [ "$_version" != "" ]; then
        OSBUILDER_VERSION=$_version
    fi
}

mkdir -p "${K3S_MANIFEST_DIR}"

readConfig

# Copy manifests, and template them

templ "VERSION" "${CRDS_VERSION}" assets/crd.yaml
cp -rf assets/crd.yaml "${K3S_MANIFEST_DIR}/kairos-crds.yaml"

if [ "$ENTANGLE_ENABLE" == "true" ]; then
    SRC="assets/entangle.yaml"
    FILE=$K3S_MANIFEST_DIR/kairos-entangle.yaml
    templ "VERSION" "${ENTANGLE_VERSION}" "${SRC}"
    cp -rf "${SRC}" "${FILE}"
fi

if [ "$ENTANGLEPROXY_ENABLE" == "true" ]; then
    SRC="assets/entangle-proxy.yaml"
    FILE=$K3S_MANIFEST_DIR/kairos-entangle-proxy.yaml
    templ "VERSION" "${ENTANGLEPROXY_VERSION}" "${SRC}"
    cp -rf "${SRC}" "${FILE}"
fi

if [ "$OSBUILDER_ENABLE" == "true" ]; then
    SRC="assets/osbuilder.yaml"
    FILE="${K3S_MANIFEST_DIR}/kairos-osbuilder.yaml"
    templ "VERSION" "${OSBUILDER_VERSION}" "${SRC}"
    cp -rf "${SRC}" "${FILE}"
fi
