#!/bin/bash

set -x
# Override with the `env` key if necessary
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

scriptdir="$( cd -- "$(dirname "$0")" || return >/dev/null 2>&1 ; pwd -P )"
flux="$scriptdir/flux"
short=2
long=900

cleanup() {
  timeout $short kubectl delete configmap -n default flux-boostrap
}

# Don't bootstrap if the cluster is already bootstrapped
if [[ $($flux version 2>/dev/null; echo $?) -eq 0 ]]; then
  echo "Flux is already bootstrapped, exiting..."
  exit 0
fi

# Determine what VCS we need to bootstrap
for vcs in bitbucket_server git github gitlab; do
  if [[ $(kairos-agent config get flux.$vcs) != "null" ]]; then
    version_control=$vcs
    break
  fi
done

if [[ "${version_control}x" == "x" ]]; then
  echo "Unable to determine what version control provider to use, exiting..."
  exit 1
fi

# Get flux envs and settings for our VCS
mapfile -t envs < <(kairos-agent config get "flux.env")
mapfile -t args < <(kairos-agent config get "flux.$version_control")
declare -a cmdline

# Set environment variables
# These are likely sensitive
set +x
for setting in "${envs[@]}"; do
  env=$(echo "$setting" | cut -d: -f1)
  value=$(echo "$setting" | cut -d':' -f2 | sed -E 's/^ //g')
  if [[ "${value}x" != "x" ]]; then
    export "$env"="$value"
  fi
done
set -x

# Set commandline args
for setting in "${args[@]}"; do
  arg=$(echo "$setting" | cut -d: -f1)
  value=$(echo "$setting" | cut -d':' -f2 | sed -E 's/^ //g')
  if [[ "${value}x" != "x" ]]; then
    cmdline+=("--$arg" "$value")
  fi 
done

# Try to bootstrap Flux for 30 minutes, sleep 15 seconds between attempts
minutes=30
sleep=15
retry_attempt=1
active="false"

if [[ "${#cmdline[@]}" -eq 0 ]]; then
  echo "Flux was not configured, not running any Flux commands"
  exit 2
else
  while [[ $retry_attempt -le "$(( minutes * 60 / sleep ))" ]]; do
    if [[ "$active" != "true" ]]; then
      # Ensure only one host tries to bootstrap, whichever makes the configmap first
      if ! timeout $short kubectl version &> /dev/null; then
        echo "Kubernetes API not ready yet, sleeping"
      else
        if ! timeout $short kubectl create configmap flux-bootstrap --from-literal=hostname="$(hostname)"; then
          echo "Unable to create configmap, another node may be active"
        fi

        # The configmap exists but we must finally check if the hostname matches
        if [[ "$(timeout $short kubectl get configmap -n default flux-bootstrap -o jsonpath='{.data.hostname}')" != "$(hostname)" ]]; then
          echo "Flux bootstrap ConfigMap exists but another node is active, exiting..."
          exit 3
        fi

        # We must be the active node
        active="true"
      fi
    else
      if timeout $long "$flux" bootstrap "${version_control/_/-}" "${cmdline[@]}"; then
        cleanup
        exit 0
      fi
    fi

    echo "Install attempt $retry_attempt failed, retrying in $sleep seconds"
    (( retry_attempt = retry_attempt + 1 ))
    sleep $sleep
  done
fi

echo "Failed to bootstrap with Flux, timed out ($minutes minutes)"
exit 4