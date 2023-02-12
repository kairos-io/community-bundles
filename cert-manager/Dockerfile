FROM alpine as build
RUN mkdir /assets
RUN wget https://github.com/cert-manager/cert-manager/releases/download/v1.11.0/cert-manager.yaml -O /assets/cert-manager-v1.11.0.yaml
FROM scratch
COPY ./run.sh /
COPY --from=build /assets /assets
