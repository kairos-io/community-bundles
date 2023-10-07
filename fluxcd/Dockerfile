FROM alpine as build
ENV VERSION=2.1.1

ADD https://github.com/fluxcd/flux2/releases/download/v${VERSION}/flux_${VERSION}_linux_amd64.tar.gz /tmp
RUN tar xzf /tmp/flux_${VERSION}_linux_amd64.tar.gz -C / && \
    rm /tmp/flux_${VERSION}_linux_amd64.tar.gz

FROM scratch
COPY --from=build /flux /flux
COPY ./bootstrap.sh /bootstrap.sh
