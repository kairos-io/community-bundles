FROM alpine as build
ARG TARGETARCH
WORKDIR /assets
RUN wget https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-$TARGETARCH -O argocd
RUN chmod +x argocd

FROM --platform=$BUILDPLATFORM scratch
COPY ./run.sh /
COPY --from=build /assets/ /assets
COPY ./assets /assets
