VERSION 0.6
FROM alpine
ARG BUNDLE
ARG VERSION="latest"
ARG IMAGE_REPOSITORY=quay.io/kairos/community-bundles

# renovate: datasource=docker depName=renovate/renovate versioning=docker
ARG RENOVATE_VERSION=37
# renovate: datasource=docker depName=koalaman/shellcheck-alpine versioning=docker
ARG SHELLCHECK_VERSION=v0.9.0

version:
    FROM alpine
    RUN apk add git

    COPY . ./

    # If "ENV/ARG VERSION=" exists in Dockerfile, version image based on that value
    # Otherwise, try to determine from tags. Failing that, v0.0.0-[git sha]
    RUN DOCKERFILE_VERSION=$(cat Dockerfile | awk -F'=' '/ VERSION=/{print $2}'); \
      if [[ "${DOCKERFILE_VERSION}x" != "x" ]]; then \
        echo "$DOCKERFILE_VERSION" > VERSION; \
      else \
        echo $(git describe --exact-match --tags || echo "v0.0.0-$(git log --oneline -n 1 | cut -d" " -f1)") > VERSION; \
      fi

    SAVE ARTIFACT VERSION VERSION

build:
    COPY +version/VERSION ./
    ARG VERSION=$(cat VERSION)
    ARG TAG_SUFFIX="latest"
    FROM DOCKERFILE -f ${BUNDLE}/Dockerfile ./${BUNDLE}
    
    # Always push the specified tag
    SAVE IMAGE --push $IMAGE_REPOSITORY:${BUNDLE}-${TAG_SUFFIX}

build-latest:
    COPY +version/VERSION ./
    ARG VERSION=$(cat VERSION)
    ARG TAG_SUFFIX="latest"
    FROM DOCKERFILE -f ${BUNDLE}/Dockerfile ./${BUNDLE}
    
    # Push as latest (only called when needed)
    SAVE IMAGE --push $IMAGE_REPOSITORY:${BUNDLE}_latest

# Multi-platform build target
build-multi:
    COPY +version/VERSION ./
    ARG VERSION=$(cat VERSION)
    ARG TAG_SUFFIX="latest"
    
    # Always build the main tag
    BUILD --platform linux/amd64 --platform linux/arm64 +build --BUNDLE=$BUNDLE --TAG_SUFFIX=$TAG_SUFFIX
    
    # If this is a version tag (starts with v), also build latest
    IF [ "${TAG_SUFFIX#v}" != "$TAG_SUFFIX" ]
        BUILD --platform linux/amd64 --platform linux/arm64 +build-latest --BUNDLE=$BUNDLE
    END

rootfs:
    FROM +build
    SAVE ARTIFACT /. rootfs

test:
    FROM quay.io/kairos/core-alpine-opensuse-leap
    RUN apk add go
    ENV GOPATH=/go
    ENV PATH=$PATH:$GOPATH/bin
    COPY (+rootfs/rootfs --BUNDLE=$BUNDLE) /bundle
    COPY . .
    RUN cd tests && \ 
        go install -mod=mod github.com/onsi/ginkgo/v2/ginkgo && \
        ginkgo --label-filter="${BUNDLE}" -v ./...

renovate-validate:
    ARG RENOVATE_VERSION
    FROM renovate/renovate:$RENOVATE_VERSION
    WORKDIR /usr/src/app
    COPY renovate.json .
    RUN renovate-config-validator

shellcheck-lint:
    ARG SHELLCHECK_VERSION
    FROM koalaman/shellcheck-alpine:$SHELLCHECK_VERSION
    WORKDIR /mnt
    COPY . .
    RUN find . -name "*.sh" -print | xargs -r -n1 shellcheck

lint:
    BUILD +renovate-validate
    BUILD +shellcheck-lint
