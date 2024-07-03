#!/bin/bash

# Override with the `flux.env.KUBECONFIG` key if necessary
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

# Seconds
short=5
long=900

configmap=flux-bootstrap

info () {
  echo $'\e[36mINFO\e[0m: ' "$1"
}

warn() {
  echo $'\e[33mWARN\e[0m:' "$1"
}

error() {
  echo $'\e[31mERROR\e[0m:' "$1"
}

cleanup() {
  info "Removing bootstrap configmap"
  timeout $short kubectl delete configmap -n default $configmap
}

# Don't bootstrap if the cluster is already bootstrapped
if flux version &>/dev/null; then
  info "Flux is already bootstrapped, exiting..."
  exit 0
fi

# Determine what VCS we need to bootstrap
# Starting in kairos  2.8.15, kairos-agent command returns empty string  instead of "null"
for vcs in bitbucket_server git github gitlab; do
  value=$(kairos-agent config get flux.$vcs 2>/dev/null)
  if [[ $value != "null" && -n $value ]]; then
    version_control=$vcs
    break
  fi
done

if [[ "${version_control}x" == "x" ]]; then
  error "Unable to determine what version control provider to use, exiting..."
  exit 1
fi

# Get flux envs and settings for our VCS
mapfile -t envs < <(kairos-agent config get "flux.env" 2>/dev/null)
mapfile -t args < <(kairos-agent config get "flux.$version_control" 2>/dev/null)
declare -a cmdline

for setting in "${envs[@]}"; do
  if [[ $setting != "null" ]]; then
    env=$(echo "$setting" | cut -d: -f1)
    value=$(echo "$setting" |  sed -n 's/^[^:]*: *//p')
    if [[ "${value}x" != "x" ]]; then
      export "$env"="$value"
    fi
  fi
done

# Set commandline args
for setting in "${args[@]}"; do
  if [[ $setting != "null" ]]; then
    arg=$(echo "$setting" | cut -d: -f1)
    value=$(echo "$setting" |  sed -n 's/^[^:]*: *//p')
    if [[ "${value}x" != "x" ]]; then
      cmdline+=("--$arg" "$value")
    fi 
  fi
done

# Try to bootstrap Flux for 30 minutes, sleep 15 seconds between attempts
minutes=30
sleep=15
retry_attempt=1
total_attempts=$(( minutes * 60 / sleep ))
active="false"

if [[ "${#cmdline[@]}" -eq 0 ]]; then
  info "Flux was not configured in cloud-config, not bootstrapping"
  exit 0
else
  while [[ $retry_attempt -le $total_attempts ]]; do
    if [[ "$active" != "true" ]]; then
      # Ensure only one host tries to bootstrap, whichever makes the configmap first
      if ! timeout $short kubectl version &> /dev/null; then
        info "Kubernetes API not ready yet, sleeping"
      else
        if ! timeout $short kubectl create configmap $configmap --from-literal=hostname="$(hostname)"; then
          warn "Unable to create configmap, another node may be active"
        fi

        # The configmap exists but we must finally check if the hostname matches
        if [[ "$(timeout $short kubectl get configmap -n default $configmap -o jsonpath='{.data.hostname}')" != "$(hostname)" ]]; then
          error "Flux bootstrap ConfigMap exists but another node is active, exiting..."
          exit 3
        fi

        # We must be the active node
        active="true"
      fi
    fi
    
    if [[ "$active" == "true" ]]; then
      if timeout $long flux bootstrap "${version_control/_/-}" "${cmdline[@]}"; then
        cleanup
        exit 0
      fi
    fi

    warn "Install attempt $retry_attempt (of $total_attempts) failed, retrying in $sleep seconds"
    (( retry_attempt = retry_attempt + 1 ))
    sleep $sleep
  done
fi

error "Failed to bootstrap with Flux, timed out ($minutes minutes)"
exit 4