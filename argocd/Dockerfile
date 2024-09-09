FROM alpine as build
# renovate: datasource=github-releases depName=argoproj/argo-cd
ENV VERSION=2.10.2
ENV CHECKSUM=a8da9fa1ea7b7072007f535d39526ad0c4a8b8eb58779b48774126335c576187
ARG TARGETARCH
ADD https://github.com/argoproj/argo-cd/releases/download/v${VERSION}/argocd-linux-amd64 /tmp
RUN DOWNLOAD_FILE="/tmp/argocd-linux-amd64" && \
    DOWNLOAD_CHECKSUM=$(sha256sum "${DOWNLOAD_FILE}" | awk '{print $1}') && \
    if [[ ${DOWNLOAD_CHECKSUM} != ${CHECKSUM} ]]; then \
      echo "Checksum does not match"; \
      exit 1; \
    fi

FROM --platform=$BUILDPLATFORM scratch
COPY ./run.sh /
COPY --from=build argocd-linux-amd64 .
COPY ./assets /assets
