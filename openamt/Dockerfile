FROM ghcr.io/kairos-io/openamt:v0.1.0-beta1 as src
FROM scratch

COPY --from=src /* /
COPY ./run.sh /
