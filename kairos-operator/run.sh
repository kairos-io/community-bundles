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

    OPERATOR_IMAGE=$(getConfig kairosOperator.images.operator)
    NODE_LABELER_IMAGE=$(getConfig kairosOperator.images.nodeLabeler)
    SENTINEL_IMAGE=$(getConfig kairosOperator.images.sentinel)
    NODEOP_DEFAULT_IMAGE=$(getConfig kairosOperator.images.nodeOpDefault)
}

processOverlay() {
    local overlay_file="$1"
    local env_name="$2"
    local env_value="$3"
    local copy_from_env_overlay="$4"

    if [ -z "$env_value" ]; then
        return
    fi

    if [ "$copy_from_env_overlay" = true ]; then
        cp "assets/overlays/env-var-image.yaml" "assets/overlays/${overlay_file}"
    fi

    sed -i "s|@ENV_NAME@|${env_name}|g" "assets/overlays/${overlay_file}"
    sed -i "s|@ENV_VALUE@|${env_value}|g" "assets/overlays/${overlay_file}"
    echo "  - path: ${overlay_file}" >> assets/overlays/kustomization.yaml
    HAS_OVERLAYS=true
}

readConfig

HAS_OVERLAYS=false

processOverlay "operator-image.yaml" "OPERATOR_IMAGE" "$OPERATOR_IMAGE"
processOverlay "operator-env.yaml" "OPERATOR_IMAGE" "$OPERATOR_IMAGE" true
processOverlay "node-labeler-env.yaml" "NODE_LABELER_IMAGE" "$NODE_LABELER_IMAGE" true
processOverlay "sentinel-env.yaml" "SENTINEL_IMAGE" "$SENTINEL_IMAGE" true
processOverlay "nodeop-default-env.yaml" "NODEOP_DEFAULT_IMAGE" "$NODEOP_DEFAULT_IMAGE" true

if [ "$HAS_OVERLAYS" = true ]; then
    cp assets/kairos-operator.yaml assets/overlays/kairos-operator.yaml
    assets/kubectl kustomize assets/overlays > assets/kairos-operator.yaml
fi

mkdir -p "${MANIFEST_DIR}"
cp -f assets/kairos-operator.yaml "${MANIFEST_DIR}"