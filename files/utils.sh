#!/bin/bash

# Function to echo and log messages to ~/log.txt
log() {
  echo $(date +%Y-%m-%dT%H:%M:%S) $1 2>&1 | tee -a ~/log.txt
}

# Function to validate IP address
is_valid_ip() {
  local ip=$1
  local pattern="^([0-9]{1,3}\.){3}[0-9]{1,3}$"

  if [[ $ip =~ $pattern ]]; then
    IFS='.' read -r -a parts <<<"$ip"

    for part in "${parts[@]}"; do
      if ! [[ "$part" -ge 0 && "$part" -le 255 ]]; then
        return 1
      fi
    done

    return 0
  else
    echo "Invalid IP address. Please try again."
    return 1
  fi
}

# Function to validate CIDR notation
is_valid_cidr() {
  local cidr=$1
  local pattern="^([0-9]{1,3}\.){3}[0-9]{1,3}/([0-9]|[1-2][0-9]|3[0-2])$"

  if [[ $cidr =~ $pattern ]]; then
    # Split the CIDR notation into IP address and subnet mask parts
    IFS='/' read -r -a parts <<<"$cidr"
    local ip=${parts[0]}
    local subnet_mask=${parts[1]}

    # Validate IP address
    local ip_pattern="^([0-9]{1,3}\.){3}[0-9]{1,3}$"
    if ! [[ $ip =~ $ip_pattern ]]; then
      return 1
    fi

    # Validate subnet mask
    local subnet_mask_pattern="^([0-9]|[1-2][0-9]|3[0-2])$"
    if ! [[ $subnet_mask =~ $subnet_mask_pattern ]]; then
      return 1
    fi

    return 0
  else
    echo "Invalid IP address in CIDR notation. Please try again."
    return 1
  fi
}

is_valid_ntp() {
  local url=$1
  if [[ $url =~ ([a-zA-Z0-9-]+(\.[a-zA-Z0-9-]*)+)(:[0-9]+)?(/.*)?$ ]]; then
    return 0
  else
    return 1
  fi
}

# Function to check if the hostname is valid
is_valid_hostname() {
    local hostname=$1

    # Check if hostname is entirely numeric
    if [[ $hostname =~ ^[0-9]+$ ]]; then
        echo "Invalid: Hostname cannot be entirely numeric."
        return 1
    fi

    # Check total length of hostname <= 64 characters which Linux is accepted
    if [[ ${#hostname} -gt 64 ]]; then
        echo "Invalid: Hostname is longer than 64 characters."
        return 1
    fi

    # RFC 1123 hostname validation pattern
    local hostname_pattern='^([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])\.?([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-]*[a-zA-Z0-9])$'

    if [[ $hostname =~ $hostname_pattern ]]; then
        return 0
    else
        log "Invalid: Hostname does not match RFC 1123 standards."
        return 1
    fi
}
