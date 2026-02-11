FROM alpine AS build
# renovate: datasource=github-releases depName=derailed/k9s
ENV VERSION=v0.50.18
ARG TARGETARCH

RUN wget -O "/tmp/k9s_Linux_${TARGETARCH}.tar.gz" "https://github.com/derailed/k9s/releases/download/${VERSION}/k9s_Linux_${TARGETARCH}.tar.gz"; \
    tar -xzf "/tmp/k9s_Linux_${TARGETARCH}.tar.gz" -C /tmp; \
    chmod +x /tmp/k9s;

FROM --platform=$BUILDPLATFORM scratch
COPY ./run.sh /
COPY --from=build /tmp/k9s .
