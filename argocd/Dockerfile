FROM alpine as build
WORKDIR /assets
RUN wget https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64 -O argocd
RUN chmod +x argocd

FROM scratch
COPY ./run.sh /
COPY --from=build /assets/ /assets
COPY ./assets /assets
