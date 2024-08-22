#!/bin/bash
. ./utils.sh

HOSTNAME=$(hostname)
NEW_HOSTNAME=$1


log "Trying to set the hostname as $NEW_HOSTNAME ..."

if ! is_valid_hostname $NEW_HOSTNAME; then
    log "New hostname is invalid."
    exit 1
fi

if [ "$HOSTNAME" == "paragon-node" ]; then
  hostnamectl set-hostname $NEW_HOSTNAME
  log "The new hostname is set to: $(hostname)"
  log "Rebuilding ssh host keys and restarting ssh"
  sleep 3
  # could back these up first
  rm /etc/ssh/ssh_host*
  ssh-keygen -A
  systemctl restart ssh
else
  log "The hostname is already set to $(hostname). The hostname will not be changed to $NEW_HOSTNAME "
fi
