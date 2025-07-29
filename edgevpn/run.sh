#!/bin/bash

set -ex

BIN=/usr/local/bin/

getConfig() {
    local key=$1
    _value=$(kairos-agent config get "${key} | @json" | tr -d '\n')
    # Remove the quotes wrapping the value.
    _value=${_value:1:${#_value}-2}
    if [ "${_value}" != "null" ]; then
     echo "${_value}"
    fi 
    echo   
}


# Copy the edgevpn binary
mkdir -p $BIN
cp edgevpn $BIN/edgevpn
chmod +x "$BIN/edgevpn"

# Detect init system and setup accordingly
if command -v systemctl >/dev/null 2>&1; then
    # Systemd setup
    echo "Setting up edgevpn for systemd"
    mkdir -p /etc/systemd/system.conf.d
    echo "EDGEVPNTOKEN=$(getConfig edgevpn.token)" > /etc/systemd/system.conf.d/edgevpn-kairos.env
    cp assets/edgevpn.service /etc/systemd/system/edgevpn.service
    # Create symlink manually instead of using systemctl enable (for container compatibility)
    mkdir -p /etc/systemd/system/multi-user.target.wants
    ln -sf /etc/systemd/system/edgevpn.service /etc/systemd/system/multi-user.target.wants/edgevpn.service
    # Start the service only if systemd is running
    if systemctl is-system-running >/dev/null 2>&1; then
        systemctl start edgevpn
    else
        echo "Systemd is available but not running. Service will start on next boot."
    fi
elif command -v rc-update >/dev/null 2>&1; then
    # OpenRC setup
    echo "Setting up edgevpn for openrc"
    # Create environment file for openrc
    mkdir -p /etc/conf.d
    echo "export EDGEVPNTOKEN=$(getConfig edgevpn.token)" > /etc/conf.d/edgevpn
    cp assets/edgevpn.openrc /etc/init.d/edgevpn
    chmod +x /etc/init.d/edgevpn
    # Enable the service for future boots
    rc-update add edgevpn default
    # Start the service immediately
    rc-service edgevpn start || true
else
    echo "Warning: Neither systemd nor openrc detected. EdgeVPN service not started."
    echo "You may need to start it manually."
fi