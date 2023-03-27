FROM alpine as build

# TODO: How do we handle different architectures?
WORKDIR /assets
RUN wget https://github.com/confidential-containers/containerd/releases/download/v1.6.8.1/containerd-1.6.8.1-linux-amd64.tar.gz -O containerd.tar.gz
RUN tar xvf containerd.tar.gz
RUN rm containerd.tar.gz

RUN wget https://raw.githubusercontent.com/containerd/containerd/release/1.6/containerd.service

FROM scratch
COPY ./run.sh /
COPY --from=build /assets/ /assets
COPY assets/. /assets
