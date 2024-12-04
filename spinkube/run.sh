#!/bin/bash

# This follows the SpinKube documentation:
# https://www.spinkube.dev/docs/install/installing-with-helm/

set -ex

manifest_dir=assets

spin_operator_version=0.4.0
kwasm_installer_version=0.17.0
cert_manager_version=1.14.5

_install_cert_manager=$(kairos-agent config get "spinkube.installCertManager" | tr -d '\n')
if [ "$_install_cert_manager" = "true" ]; then
    sudo k3s kubectl apply -f "$manifest_dir/cert-manager-$cert_manager_version.yaml"

    # Wait for the various cert-manager resources to be ready before proceeding
    sudo k3s kubectl wait --for=condition=available --timeout=300s deployment/cert-manager -n cert-manager
    sudo k3s kubectl wait --for=condition=available --timeout=300s deployment/cert-manager-webhook -n cert-manager
    sudo k3s kubectl wait --for=condition=available --timeout=300s deployment/cert-manager-cainjector -n cert-manager
fi

# Check to make sure the kwasm namespace doesn't already exist
if ! sudo k3s kubectl get namespace kwasm > /dev/null 2>&1; then
    sudo k3s kubectl create namespace kwasm
fi

# Check to make sure the spin-operator namespace doesn't already exist
if ! sudo k3s kubectl get namespace spin-operator > /dev/null 2>&1; then
    sudo k3s kubectl create namespace spin-operator
fi

# Install Kwasm Operator
sudo k3s kubectl apply --namespace kwasm -f "$manifest_dir/kwasm-operator-$kwasm_installer_version.yaml"

# Provision Nodes
sudo k3s kubectl annotate node --all kwasm.sh/kwasm-node=true

# Install Spin Operator Resources
sudo k3s kubectl apply -f "$manifest_dir/spin-operator-$spin_operator_version.crds.yaml"
sudo k3s kubectl apply -f "$manifest_dir/spin-operator-$spin_operator_version.runtime-class.yaml"
sudo k3s kubectl apply -f "$manifest_dir/spin-operator-$spin_operator_version.shim-executor.yaml"

# Install Spin Operator
sudo k3s kubectl apply --namespace spin-operator -f "$manifest_dir/spin-operator-$spin_operator_version.yaml"
# Wait for the spin-operator-controller-manager to be ready
sudo k3s kubectl wait --namespace spin-operator --for=condition=available --timeout=300s deployment/spin-operator-controller-manager