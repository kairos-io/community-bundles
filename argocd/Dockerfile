FROM --platform=$BUILDPLATFORM alpine as build
ARG TARGETARCH
WORKDIR /assets
RUN wget https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-$TARGETARCH -O argocd
RUN chmod +x argocd

FROM scratch
COPY ./run.sh /
COPY --from=build /assets/ /assets
COPY ./assets /assets
