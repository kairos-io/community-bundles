#!/bin/bash

set -ex

BIN=/usr/local/bin

# Copy the qemu-ga binary to /usr/local/bin (mutable path in Kairos)
mkdir -p $BIN
cp qemu-ga $BIN/qemu-ga
chmod +x "$BIN/qemu-ga"

# Detect init system and setup accordingly
if command -v systemctl >/dev/null 2>&1; then
    echo "Setting up qemu-guest-agent for systemd"

    cp assets/qemu-guest-agent.service /etc/systemd/system/qemu-guest-agent.service
    mkdir -p /etc/systemd/system/multi-user.target.wants
    ln -sf /etc/systemd/system/qemu-guest-agent.service /etc/systemd/system/multi-user.target.wants/qemu-guest-agent.service

    if systemctl is-system-running >/dev/null 2>&1; then
        systemctl start qemu-guest-agent
        systemctl enable qemu-guest-agent
    else
        echo "Systemd is available but not running. Service will start on next boot."
    fi

else
    echo "Warning: systemd not detected. qemu-guest-agent service not started."
    echo "You may need to start it manually."
    exit 0
fi