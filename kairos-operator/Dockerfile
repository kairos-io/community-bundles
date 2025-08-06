FROM alpine:latest as build

# Install kubectl for kustomize and git
RUN apk add --no-cache curl git
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

# Clone the repository at the specific tag version
RUN git clone --depth 1 --branch @VERSION@ https://github.com/kairos-io/kairos-operator.git /tmp/kairos-operator

# Generate the kairos-operator manifest using the specific version
RUN cd /tmp/kairos-operator/config/default && kubectl kustomize . > /kairos-operator.yaml

FROM scratch
COPY --from=build /kairos-operator.yaml /assets/kairos-operator.yaml
COPY ./run.sh / 