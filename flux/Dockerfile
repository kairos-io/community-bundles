FROM alpine AS build
# renovate: datasource=github-releases depName=fluxcd/flux2
ENV VERSION=2.6.4
ENV AMD64_CHECKSUM=9d3e21ad53baa0d5a062e1bd6f1a22d18b95906c682845bca9ffa272cff8a590
ENV ARM64_CHECKSUM=674e605f527841bb9b50a692b3ce497752cfc81438f85b4d1523d86aca637353
ARG TARGETARCH

COPY flux-download.sh .
RUN chmod +x flux-download.sh && ./flux-download.sh

FROM scratch
COPY --from=build flux .
COPY flux-bootstrap.service .
COPY flux-bootstrap.sh .
COPY run.sh .
