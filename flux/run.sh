#!/bin/bash
set -x

bin=/usr/local/bin/
system=/etc/systemd/system/

mkdir -p "$bin"
cp flux "$bin"
cp flux-bootstrap.sh "$bin"
cp flux-bootstrap.service "$system"
systemctl enable flux-bootstrap