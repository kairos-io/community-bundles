FROM alpine:3.19 AS builder

ARG spin_operator_version=0.4.0
ARG kwasm_installer_version=0.17.0
ARG cert_manager_version=1.14.5

RUN apk update && apk add --no-cache helm

WORKDIR /assets

# This follows the SpinKube documentation:
# https://www.spinkube.dev/docs/install/installing-with-helm/
RUN <<EOR
# Cert Manager
wget -O cert-manager-${cert_manager_version}.yaml https://github.com/cert-manager/cert-manager/releases/download/v${cert_manager_version}/cert-manager.yaml

# Kwasm Operator (namespace set in run.sh)
helm repo add kwasm http://kwasm.sh/kwasm-operator/
helm template kwasm-operator \
    --namespace kwasm \
    --set kwasmOperator.installerImage=ghcr.io/spinkube/containerd-shim-spin/node-installer:v${kwasm_installer_version} \
    kwasm/kwasm-operator \
> kwasm-operator-${kwasm_installer_version}.yaml

# Spin Operator CRDs
wget -O spin-operator-${spin_operator_version}.crds.yaml https://github.com/spinkube/spin-operator/releases/download/v${spin_operator_version}/spin-operator.crds.yaml

# Spin Operator Runtime Class
wget -O spin-operator-${spin_operator_version}.runtime-class.yaml https://github.com/spinkube/spin-operator/releases/download/v${spin_operator_version}/spin-operator.runtime-class.yaml

# Spin Operator Shim Executor
wget -O spin-operator-${spin_operator_version}.shim-executor.yaml https://github.com/spinkube/spin-operator/releases/download/v${spin_operator_version}/spin-operator.shim-executor.yaml

# Spin Operator (namespace set in run.sh, as is the wait command)
helm template spin-operator \
    --namespace spin-operator \
    --version ${spin_operator_version} \
    oci://ghcr.io/spinkube/charts/spin-operator \
> spin-operator-${spin_operator_version}.yaml
EOR

FROM scratch
COPY --from=builder /assets ./assets
COPY run.sh .