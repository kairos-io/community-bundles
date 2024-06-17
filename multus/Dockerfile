FROM alpine as builder

ARG TARGETARCH

# renovate: datasource=github-releases depName=k8snetworkplumbingwg/multus-cni extractVersion=^v(?<version>.*)$
ARG MULTUS_VERSION=4.0.2

# renovate: datasource=github-releases depName=containernetworking/plugins extractVersion=^v(?<version>.*)$
ARG PLUGINS_VERSION=1.5.1

WORKDIR /build

RUN apk add curl && \
    curl -fsSL --remote-name-all \
        https://github.com/k8snetworkplumbingwg/multus-cni/releases/download/v${MULTUS_VERSION}/{checksums.txt,multus-cni_${MULTUS_VERSION}_linux_${TARGETARCH}.tar.gz} \
        https://github.com/containernetworking/plugins/releases/download/v${PLUGINS_VERSION}/cni-plugins-linux-${TARGETARCH}-v${PLUGINS_VERSION}.tgz{.sha256,} && \
    grep ${TARGETARCH} checksums.txt | sha256sum -cs && \
    sha256sum -cs cni-plugins-linux-${TARGETARCH}-v${PLUGINS_VERSION}.tgz.sha256 && \
    tar -xf multus-cni_${MULTUS_VERSION}_linux_${TARGETARCH}.tar.gz --strip-components 1 \
        multus-cni_${MULTUS_VERSION}_linux_${TARGETARCH}/multus && \
    mkdir plugins && \
    tar -xC plugins -f cni-plugins-linux-${TARGETARCH}-v${PLUGINS_VERSION}.tgz

FROM scratch

COPY --from=builder /build/multus /multus
COPY --from=builder /build/plugins /plugins
COPY ./manifests.yaml /
COPY ./run.sh /
