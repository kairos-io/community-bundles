#!/bin/bash

set -ex

VERSION=${VERSION:-v0.0.1}

# Create a temporary Dockerfile with the version replaced
sed "s/@VERSION@/${VERSION}/g" Dockerfile > Dockerfile.tmp

# Build the image
docker build -f Dockerfile.tmp -t kairos-operator-test .

# Clean up
rm Dockerfile.tmp 