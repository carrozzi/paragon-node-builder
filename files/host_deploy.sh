#!/bin/bash
. ./utils.sh

RUNTIME=/root

ask_question() {
  local question=$1
  local response

  read -p "$question (y/n): " response
  response=$(echo "$response" | tr '[:upper:]' '[:lower:]')  # Convert response to lowercase

  # Check the response
  if [[ $response == "y" || $response == "yes" ]]; then
    return 0  # Return success (yes)
  elif [[ $response == "n" || $response == "no" ]]; then
    return 1  # Return failure (no)
  else
    echo "Invalid response. Please answer 'yes' or 'no'."
    ask_question "$question"  # Ask the question again
  fi
}

if [[ -f "/etc/systemd/system/getty@tty1.service.d/override.conf" ]]; then
  sudo rm -rf /etc/systemd/system/getty@tty1.service.d/override.conf
  echo "Password is set successfully!"

  sudo systemctl restart getty@tty1.service
fi

ORIG_HOSTNAME=`hostname`
if [ $ORIG_HOSTNAME == "paragon-node" ]; then
  if ask_question "Do you want to set up Hostname?"; then
    read -p "Please specify the Hostname: " HOSTNAME
    until is_valid_hostname "$HOSTNAME"; do
      read -p "Please specify the Hostname: " HOSTNAME
    done
    sudo bash set_hostname.sh $HOSTNAME
  fi
fi

is_ip_in_netplan() {
    local ipaddr="$1"
    if [ -z "$ipaddr" ]; then
        return 0
    fi
    sudo egrep -q $ipaddr /etc/netplan/*.yaml
    if [ $? -eq 0 ]; then
        return 1
    fi
    return 0
}

# host might eventually have multiple IP addrs, e.g ui/mgmt/network
ORIG_IP=`hostname -I | sed 's/172.17.0.* //' | awk '{print $1}'`
if [ ! -z "$ORIG_IP" ]; then
    is_ip_in_netplan $ORIG_IP
  if [ $? -gt 0 ]; then 
      echo "This Controller IP: $ORIG_IP"
      exit 0
  fi
  echo "This Controller IP: $ORIG_IP"
  echo "Static IP is not configured but is recommended"
  echo "DHCP or non persistent setting might be in use."
fi

if ask_question "Do you want to set up Static IP (preferred)?"; then
  echo ""
else
  echo "No IP address configuration will be updated"
  exit 0
fi

# Gather input from user
get_input() {
    # IP_ADDRESS
  read -p "Please specify the IP address in CIDR notation (such as 192.168.1.2/24): " IP_ADDRESS
  until is_valid_cidr "$IP_ADDRESS"; do
    read -p "Please specify the IP address in CIDR notation (such as 192.168.1.2/24): " IP_ADDRESS
  done

  # GATEWAY_ADDRESS
  read -p "Please specify the Gateway IP: " GATEWAY_ADDRESS
  until is_valid_ip "$GATEWAY_ADDRESS"; do
    read -p "Please specify the Gateway IP: " GATEWAY_ADDRESS
  done

  # PRIMARY_DNS_ADDRESS
  read -p "Please specify the Primary DNS IP: " PRIMARY_DNS_ADDRESS
  until is_valid_ip "$PRIMARY_DNS_ADDRESS"; do
    read -p "Please specify the Primary DNS IP: " PRIMARY_DNS_ADDRESS
  done

  # SECONDARY_DNS_ADDRESS
  read -p "Please specify the Secondary DNS IP: " SECONDARY_DNS_ADDRESS
  until is_valid_ip "$SECONDARY_DNS_ADDRESS"; do
    read -p "Please specify the Secondary DNS IP: " SECONDARY_DNS_ADDRESS
  done
}

INTERFACE=`ip -br l | awk '$1 !~ "lo|vir|wl" { print $1}' | head -n 1`
echo "Gathering IP information for interface $INTERFACE"

get_input
# verify
echo
echo
echo
echo "======================================================="
echo "=================  PLEASE CONFIRM  ===================="
echo "======================================================="
echo
echo "You are setting Static IP with these values in netplan:"
echo "Interface                    : " $INTERFACE
echo "IP address in CIDR notation  : " $IP_ADDRESS
echo "Gateway IP                   : " $GATEWAY_ADDRESS
echo "Primary DNS IP               : " $PRIMARY_DNS_ADDRESS
echo "Secondary DNS IP             : " $SECONDARY_DNS_ADDRESS
echo

while true; do
  read -p "Are you sure you want to proceed? [Y/n]" confirm
  if [[ ! $confirm =~ ^[Yy]$ ]]; then
    echo "Regathering inputs, hit Control-C to exit this step"
    get_input
  else
    break
  fi
done

echo "If you used ssh to log in, you may need to log in again with new IP."

# Apply network config to netplan yaml config file
# Making some assumptions here about the adapter name

cat > /tmp/00-installer-config.yaml <<EOF
network:
  version: 2
  ethernets:
    $INTERFACE:
      dhcp4: false
      dhcp6: no
      link-local: []
      addresses: [$IP_ADDRESS]
      routes:
        - to: default
          via: $GATEWAY_ADDRESS
      nameservers:
        addresses: [$PRIMARY_DNS_ADDRESS, $SECONDARY_DNS_ADDRESS]
EOF
sudo cp /tmp/00*.yaml /etc/netplan
sudo chmod 600 /etc/netplan/00-installer-config.yaml
sudo rm -rf /etc/netplan/00-installer-config.bak*
sudo netplan apply
rm -f host_deploy.sh
exit $?
