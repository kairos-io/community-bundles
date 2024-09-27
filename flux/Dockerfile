FROM alpine AS build
# renovate: datasource=github-releases depName=fluxcd/flux2
ENV VERSION=2.3.0
ENV CHECKSUM=51ef10a0ebf2078e52476c4d168200a1db73feef987e0bc8722f4ce4fcd4b6d9

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
