#!/bin/sh
set -e

if [ "$TARGETARCH" = "amd64" ]; then
    CHECKSUM="$AMD64_CHECKSUM"
elif [ "$TARGETARCH" = "arm64" ]; then
    CHECKSUM="$ARM64_CHECKSUM"
else
    echo "Unsupported architecture: $TARGETARCH"
    exit 1
fi

DOWNLOAD_FILE="flux_${VERSION}_linux_${TARGETARCH}.tar.gz"
wget "https://github.com/fluxcd/flux2/releases/download/v${VERSION}/${DOWNLOAD_FILE}" -O "$DOWNLOAD_FILE"

DOWNLOAD_CHECKSUM=$(sha256sum "$DOWNLOAD_FILE" | awk '{print $1}')
if [ "$DOWNLOAD_CHECKSUM" != "$CHECKSUM" ]; then
    echo "Checksum verification failed"
    exit 1
fi

tar xzf "$DOWNLOAD_FILE"
