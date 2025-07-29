FROM alpine AS build
# renovate: datasource=github-releases depName=mudler/edgevpn
ENV VERSION=0.30.2
ARG TARGETARCH

RUN if [[ "$TARGETARCH" = "amd64" ]]; then \
      export CHECKSUM=45073d7e0fd0a38bfa7fc634fc7f603e6c636e933f8b8ff25a21fa589abce18a; \
      export ARCH=x86_64; \
    elif [[ "$TARGETARCH" = "arm64" ]]; then \
      export CHECKSUM=b4a8be84ec9a886bfb38560ed0cc9a8b3f48748c7ca0a60265204de42026854e; \
      export ARCH=arm64; \
    fi && \
      echo "CHECKSUM=${CHECKSUM}" >> /tmp/edgevpn_env && \
      echo "ARCH=${ARCH}" >> /tmp/edgevpn_env

RUN source /tmp/edgevpn_env; \
  echo "CHECKSUM is: ${CHECKSUM}"; \
  echo "ARCH is: ${ARCH}"; \
  wget -O "/tmp/edgevpn-v${VERSION}-Linux-${ARCH}.tar.gz" "https://github.com/mudler/edgevpn/releases/download/v${VERSION}/edgevpn-v${VERSION}-Linux-${ARCH}.tar.gz"; \
  DOWNLOAD_FILE="/tmp/edgevpn-v${VERSION}-Linux-${ARCH}.tar.gz"; \
  DOWNLOAD_CHECKSUM=$(sha256sum "${DOWNLOAD_FILE}" | awk '{print $1}'); \
  if [[ ${DOWNLOAD_CHECKSUM} != ${CHECKSUM} ]]; then \
    echo "Checksum does not match"; \
    exit 1; \
  fi; \
  tar -xzf "${DOWNLOAD_FILE}" -C /tmp; \
  chmod +x /tmp/edgevpn;

FROM --platform=$BUILDPLATFORM scratch
COPY ./run.sh /
COPY --from=build /tmp/edgevpn .
COPY ./assets /assets