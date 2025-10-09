ARG ALPINE_VERSION=3.20
ARG QEMU_REF=v10.0.4

FROM debian:bookworm-slim AS build

RUN apt-get update && apt-get install -y --no-install-recommends \
  bash git build-essential meson ninja-build python3 python3-venv pkg-config \
  libglib2.0-dev libcap-ng-dev libmount-dev uuid-dev ca-certificates \
  && rm -rf /var/lib/apt/lists/*

ARG QEMU_REF

WORKDIR /src
RUN git clone --depth=1 --branch "${QEMU_REF}" https://github.com/qemu/qemu.git .

RUN ./configure \
      --prefix=/usr \
      --disable-werror \
      --enable-guest-agent \
      --disable-tools \
      --disable-system \
      --disable-user

      RUN make -j"$(nproc)" qemu-ga
RUN DESTDIR=/pkg make install


FROM scratch
COPY run.sh /run.sh
COPY --from=build /pkg/usr/bin/qemu-ga .
COPY ./assets /assets
ENTRYPOINT ["/run.sh"]
