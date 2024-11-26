#!/usr/bin/env bash
# Print commands and arguments as they are executed in the build
set -x
# Make apt-get non-interactive
export DEBIAN_FRONTEND=noninteractive
# Get username
username=`logname`
echo "AllowTcpForwarding yes" >> /etc/ssh/sshd_config
apt update
apt upgrade -y
apt install -y python3
apt install -y apt-transport-https bash-completion gdisk iptables lvm2 openssl
apt install -y ca-certificates curl docker.io jq keepalived 
apt install -y net-tools tcpdump traceroute
apt install iptables-persistent -y
cat > /etc/iptables/rules.v4 << EOF
*filter
:INPUT ACCEPT
:FORWARD ACCEPT
:OUTPUT ACCEPT
COMMIT
*nat
:PREROUTING ACCEPT
:INPUT ACCEPT
:OUTPUT ACCEPT
:POSTROUTING ACCEPT
COMMIT
EOF
rm /etc/iptables/rules.v6
apt install chrony -y
usermod -aG docker paragon
echo "vm.max_map_count=262144" >> /etc/sysctl.conf
echo "fs.file-max = 2097152" >> /etc/sysctl.conf
echo "fs.inotify.max_user_watches=524288" >> /etc/sysctl.conf
echo "fs.inotify.max_user_instances=512" >> /etc/sysctl.conf

echo "*         hard    nofile      1048576" >> /etc/security/limits.conf
echo "*         soft    nofile      1048576" >> /etc/security/limits.conf
echo "root      hard    nofile      1048576" >> /etc/security/limits.conf
echo "root      soft    nofile      1048576" >> /etc/security/limits.conf
echo "influxdb  hard    nofile      1048576" >> /etc/security/limits.conf
echo "influxdb  soft    nofile      1048576" >> /etc/security/limits.conf
mv /tmp/Paragon* ~paragon
tar zxvf Paragon*
rm Paragon*.gz
chown -R paragon:paragon Paragon*
cp /tmp/*.sh ~paragon
rm ~paragon/script*.sh
sed -i 's/GRUB_CMDLINE_LINUX="/GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0/' /etc/default/grub
update-grub
echo "if [ -f ~/host_deploy.sh ]; then" >> ~paragon/.bashrc
echo "    bash ~paragon/host_deploy.sh" >> ~paragon/.bashrc
echo "fi" >> ~paragon/.bashrc
chown paragon:paragon ~paragon/.bashrc

