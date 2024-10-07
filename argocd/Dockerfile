FROM alpine as build
# renovate: datasource=github-releases depName=argoproj/argo-cd
ENV VERSION=2.10.2 
ARG TARGETARCH
RUN if [[ "$TARGETARCH" = "amd64" ]]; then \
      export CHECKSUM=a8da9fa1ea7b7072007f535d39526ad0c4a8b8eb58779b48774126335c576187; \
    elif [[ "$TARGETARCH" = "arm64" ]]; then \
      export CHECKSUM=8314c9fda218145344cb0af68ceb8f31338bf11ab4ec315ba553cf6268e17444; \
    fi && \
      echo "CHECKSUM=${CHECKSUM}" > /tmp/checksum_env
RUN source /tmp/checksum_env && echo "CHECKSUM is: ${CHECKSUM}"
ADD "https://github.com/argoproj/argo-cd/releases/download/v${VERSION}/argocd-linux-${TARGETARCH}" /tmp
RUN DOWNLOAD_FILE="/tmp/argocd-linux-${TARGETARCH}" && \
    DOWNLOAD_CHECKSUM=$(sha256sum "${DOWNLOAD_FILE}" | awk '{print $1}') && \
    if [[ ${DOWNLOAD_CHECKSUM} != ${CHECKSUM} ]]; then \
      echo "Checksum does not match"; \
      exit 1; \
    fi

FROM --platform=$BUILDPLATFORM scratch
ARG TARGETARCH
COPY ./run.sh /
COPY --from=build /tmp/argocd-linux-${TARGETARCH} .
COPY ./assets /assets
