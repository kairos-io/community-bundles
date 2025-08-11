#!/bin/bash

set -ex

BIN=/usr/local/bin/

# Copy the k9s binary to /usr/local/bin (mutable path in Kairos)
mkdir -p $BIN
cp k9s $BIN/k9s
chmod +x "$BIN/k9s"

echo "k9s bundle installed successfully"
echo "k9s binary is available at $BIN/k9s"
echo "You can now run 'k9s' from the command line to manage your Kubernetes cluster"
