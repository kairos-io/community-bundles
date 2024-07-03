FROM alpine AS build
# renovate: datasource=github-releases depName=fluxcd/flux2
ENV VERSION=2.3.0
ENV CHECKSUM=61b360b50d6cfc34410730b1cebeb75f5eda2b484e47b9a083412f51ad56de68

ADD https://github.com/fluxcd/flux2/releases/download/v${VERSION}/flux_${VERSION}_linux_amd64.tar.gz /tmp
RUN DOWNLOAD_FILE="/tmp/flux_${VERSION}_linux_amd64.tar.gz" && \
    DOWNLOAD_CHECKSUM=$(sha256sum "${DOWNLOAD_FILE}" | awk '{print $1}') && \
    if [[ ${DOWNLOAD_CHECKSUM} != ${CHECKSUM} ]]; then \
      echo "Checksum does not match"; \
      exit 1; \
    fi && \
    tar xzf "${DOWNLOAD_FILE}" -C / && \
    rm "${DOWNLOAD_FILE}"

FROM scratch
COPY --from=build flux .
COPY flux-bootstrap.service .
COPY flux-bootstrap.sh .
COPY run.sh .
