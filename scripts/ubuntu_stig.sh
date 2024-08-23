#!/usr/bin/env bash
# Print commands and arguments as they are executed in the build
set -x
# Make apt-get non-interactive
export DEBIAN_FRONTEND=noninteractive
# Get username
username=`logname`
# Install required software
#apt-get -y install vim git inotify-tools python3-pip docker-compose
# Install required python libraries
#python3 -m pip install docker jinja2 pydenticon

# UBTU-22-215010	
apt-get -y install libpam-pwquality
# UBTU-22-653010
apt-get -y install auditd
# UBTU-22-653015
systemctl enable auditd.service --now
# UBTU-22-653020
apt-get -y install audispd-plugins
# UBTU-22-651010
apt-get -y install aide
# UBTU-22-412025
apt-get -y install vlock
# UBTU-22-215015
apt-get -y install chrony
# Enable serial console access. Required for console to work in NFX.
#systemctl enable serial-getty@ttyS0.service
#systemctl start serial-getty@ttyS0.service
# Disable MOTD
#sed -i '/Enabled/ s/1/0/' /etc/default/motd-news
#touch /home/$username/.hushlogin
# create STIG group
#gpasswd stig -a $username

# STIG Ubuntu:
# UBTU-22-411045
sed -i '/pam_unix.so/a auth     sufficient     pam_faillock.so authsucc' /etc/pam.d/common-auth
sed -i '/pam_unix.so/a auth     [default=die]  pam_faillock.so authfail'  /etc/pam.d/common-auth


sed -i 's/# audit/audit/' /etc/security/faillock.conf
sed -i 's/# silent/silent/' /etc/security/faillock.conf
sed -i 's/# deny/deny/' /etc/security/faillock.conf
sed -i 's/# fail_interval/fail_interval/' /etc/security/faillock.conf
sed -i 's/# unlock_time/unlock_time/' /etc/security/faillock.conf
sed -i '/unlock_time/ s/[0-9]\+/0/' /etc/security/faillock.conf
# UBTU-22-412010
echo "auth required pam_faildelay.so delay=4000000" >> /etc/pam.d/common-auth
# UBTU-22-611055,UBTU-22-611050
sed -i 's/pam_unix.so.*/pam_unix.so obscure sha512 shadow remember=5 rounds=5000/' /etc/pam.d/common-password
# UBTU-22-411025
sed -i '/PASS_MIN_DAYS/ s/[0-9]\+/1/' /etc/login.defs
# UBTU-22-411030
sed -i '/PASS_MAX_DAYS/ s/[0-9]\+/60/' /etc/login.defs
# UBTU-22-412030
echo TMOUT=900 >> /etc/profile.d/99-terminal_tmout.sh
# UBTU-22-412035
sed -i '/UMASK/ s/[0-9]\+/077/' /etc/login.defs
# UBTU-22-255060
echo "KexAlgorithms ecdh-sha2-nistp256,ecdh-sha2-nistp384,ecdh-sha2-nistp521,diffie-hellman-group-exchange-sha256" >> /etc/ssh/sshd_config
# UBTU-22-255030
sed -i 's/#ClientAliveCountMax/ClientAliveCountMax/' /etc/ssh/sshd_config
sed -i '/ClientAliveCountMax/ s/[0-9]\+/1/' /etc/ssh/sshd_config
# UBTU-22-255035
sed -i 's/#ClientAliveInterval/ClientAliveInterval/' /etc/ssh/sshd_config
sed -i '/ClientAliveInterval/ s/[0-9]\+/600/' /etc/ssh/sshd_config
# UBTU-22-255020
cp /tmp/issue.net /etc
sed -i 's/#Banner/Banner/' /etc/ssh/sshd_config
sed -i '/Banner/ s/none/\/etc\/issue.net/' /etc/ssh/sshd_config
# UBTU-22-255055
sed -i '$ a MACs hmac-sha2-512,hmac-sha2-512-etm@openssh.com,hmac-sha2-256,hmac-sha2-256-etm@openssh.com' /etc/ssh/sshd_config
# UBTU-22-255050
sed -i '$ a Ciphers aes256-ctr,aes256-gcm@openssh.com,aes192-ctr,aes128-ctr,aes128-gcm@openssh.com' /etc/ssh/sshd_config
# UBTU-22-255025
sed -i 's/#PermitEmptyPasswords/PermitEmptyPasswords/' /etc/ssh/sshd_config
sed -i 's/#PermitUserEnvironment/PermitUserEnvironment/' /etc/ssh/sshd_config
# UBTU-22-255040
sed -i '/X11Forwarding/ s/yes/no/' /etc/ssh/sshd_config
# UBTU-22-255045
sed -i 's/#X11UseLocalhost/X11UseLocalhost/' /etc/ssh/sshd_config
systemctl restart ssh
# UBTU-22-611045
sed -i 's/# enforcing/enforcing/' /etc/security/pwquality.conf
# UBTU-22-611010
sed -i 's/# ucredit/ucredit/' /etc/security/pwquality.conf
sed -i '/ucredit/ s/[0-9]\+/-1/' /etc/security/pwquality.conf
# UBTU-22-611015
sed -i 's/# lcredit/lcredit/' /etc/security/pwquality.conf
sed -i '/lcredit/ s/[0-9]\+/-1/' /etc/security/pwquality.conf
# UBTU-22-611020
sed -i 's/# dcredit/dcredit/' /etc/security/pwquality.conf
sed -i '/dcredit/ s/[0-9]\+/-1/' /etc/security/pwquality.conf
# UBTU-22-611040
sed -i 's/# difok/difok/' /etc/security/pwquality.conf
sed -i '/difok/ s/[0-9]\+/8/' /etc/security/pwquality.conf
# UBTU-22-611035
sed -i 's/# minlen/minlen/' /etc/security/pwquality.conf
sed -i '/minlen/ s/[0-9]\+/15/' /etc/security/pwquality.conf
# UBTU-22-611025
sed -i 's/# ocredit/ocredit/' /etc/security/pwquality.conf
sed -i '/ocredit/ s/[0-9]\+/-1/' /etc/security/pwquality.conf
# UBTU-22-611030
sed -i 's/# dictcheck/dictcheck/' /etc/security/pwquality.conf
sed -i '/dictcheck/ s/[0-9]\+/1/' /etc/security/pwquality.conf
# UBTU-20-010070
#sed -i '/pam_unix.so/ s/$/ remember=5/' /etc/pam.d/common-password
# UBTU-20-010100, UBTU-20-010101, UBTU-20-010102, UBTU-20-010103, UBTU-20-010104, UBTU-20-010136, UBTU-20-010137, UBTU-20-010138, UBTU-20-010139, UBTU-20-010140
# UBTU-20-010141, UBTU-20-010142, UBTU-20-010143, UBTU-20-010144, UBTU-20-010145, UBTU-20-010146, UBTU-20-010147, UBTU-20-010148, UBTU-20-010149, UBTU-20-010150
# UBTU-20-010151, UBTU-20-010152, UBTU-20-010153, UBTU-20-010154, UBTU-20-010155, UBTU-20-010156, UBTU-20-010157, UBTU-20-010158, UBTU-20-010159, UBTU-20-010160
# UBTU-20-010161, UBTU-20-010162, UBTU-20-010163, UBTU-20-010164, UBTU-20-010165, UBTU-20-010166, UBTU-20-010167, UBTU-20-010168, UBTU-20-010169, UBTU-20-010170
# UBTU-20-010171, UBTU-20-010172, UBTU-20-010173, UBTU-20-010174, UBTU-20-010175, UBTU-20-010176, UBTU-20-010177, UBTU-20-010178, UBTU-20-010179, UBTU-20-010180
# UBTU-20-010181, UBTU-20-010211, UBTU-20-010244, UBTU-20-010267, UBTU-20-010268, UBTU-20-010269, UBTU-20-010270, UBTU-20-010276, UBTU-20-010277, UBTU-20-010278
# UBTU-20-010279, UBTU-20-010296, UBTU-20-010297, UBTU-20-010298
cp /tmp/stig.rules /etc/audit/rules.d
chown root:root /etc/audit/rules.d/stig.rules
sudo augenrules --load
# UBTU-22-653030
sed -i 's/disk_full_action = .*/disk_full_action = HALT/' /etc/audit/auditd.conf
# UBTU-22-653040
sed -i 's/space_left_action = .*/space_left_action = email/' /etc/audit/auditd.conf
# UBTU-22-653055
sed -i 's/log_group = .*/log_group = root/' /etc/audit/auditd.conf
# UBTU-22-653045
chmod 0600 /var/log/audit/*
# UBTU-22-653065
chmod -R 640 /etc/audit/rules.d/*
# UBTU-22-212015
sed -i '/GRUB_CMDLINE_LINUX=/ s/""/"audit=1"/' /etc/default/grub
# UBTU-22-412020
sed -i '1i* hard maxlogins 10' /etc/security/limits.conf
# UBTU-22-652015
sed -i '$ a daemon.\* /var/log/messages' /etc/rsyslog.d/50-default.conf
sed -i '$ a auth.\*,authpriv.\* /var/log/secure' /etc/rsyslog.d/50-default.conf
# UBTU-22-411035
useradd -D -f 35
# UBTU-22-232145
find / -type d -perm -002 ! -perm 1000 -exec chmod +t '{}' \;
# UBTU-22-232026
find /var/log -perm /137 ! -name '*[bw]tmp' ! -name '*lastlog' -type f -exec chmod 640 '{}' \;
# UBTU-22-232027
sed -i 's/\(2750\|2755\)/2640/' /usr/lib/tmpfiles.d/systemd.conf
# UBTU-22-232025
chmod 0750 /var/log
# UBTU-22-215020
dpkg -P --force-all systemd-timesyncd
# UBTU-22-232140
chmod 740 /usr/bin/journalctl
# UBTU-22-232075
find /lib /usr/lib /lib64 ! -group root -type f -exec chgrp root '{}' \;
# UBTU-22-651020
sed -i '$ a SILENTREPORTS=no' /etc/default/aide
# UBTU-22-214015
sed -i 's/\/\/Unattended-Upgrade::Remove-Unused-Dependencies/Unattended-Upgrade::Remove-Unused-Dependencies/' /etc/apt/apt.conf.d/50unattended-upgrades
sed -i '/Unattended-Upgrade::Remove-Unused-Dependencies/ s/"false"/"true"/' /etc/apt/apt.conf.d/50unattended-upgrades
sed -i 's/\/\/Unattended-Upgrade::Remove-Unused-Kernel-Packages/Unattended-Upgrade::Remove-Unused-Kernel-Packages/' /etc/apt/apt.conf.d/50unattended-upgrades
# UBTU-22-412015
sed -i '/pam_lastlog.so/ s/optional/required/' /etc/pam.d/login
sed -i 's/pam_lastlog.so$/pam_lastlog.so showfailed/' /etc/pam.d/login
# UBTU-22-232050
find /bin /sbin /usr/bin /usr/sbin /usr/local/bin /usr/local/sbin ! -user root -type f -exec chown root '{}' \;
# UBTU-22-651030
sed -i '$ a /sbin/auditctl p+i+n+u+g+s+b+acl+xattrs+sha512' /etc/aide/aide.conf
sed -i '$ a /sbin/auditd p+i+n+u+g+s+b+acl+xattrs+sha512' /etc/aide/aide.conf
sed -i '$ a /sbin/ausearch p+i+n+u+g+s+b+acl+xattrs+sha512' /etc/aide/aide.conf 
sed -i '$ a /sbin/aureport p+i+n+u+g+s+b+acl+xattrs+sha512' /etc/aide/aide.conf 
sed -i '$ a /sbin/autrace p+i+n+u+g+s+b+acl+xattrs+sha512' /etc/aide/aide.conf 
sed -i '$ a /sbin/audispd p+i+n+u+g+s+b+acl+xattrs+sha512' /etc/aide/aide.conf 
sed -i '$ a /sbin/augenrules p+i+n+u+g+s+b+acl+xattrs+sha512' /etc/aide/aide.conf
# UBTU-22-291010
echo "install usb-storage /bin/false" >> /etc/modprobe.d/stig.conf
echo "blacklist usb-storage" >> /etc/modprobe.d/stig.conf
# UBTU-22-214010
sed -i '$ a APT::Get::AllowUnauthenticated "false";' /etc/apt/apt.conf.d/01-vendor-ubuntu
# UBTU-22-211015
systemctl disable ctrl-alt-del.target
systemctl mask ctrl-alt-del.target
# UBTU-22-432010
rm /etc/sudoers.d/90-cloud-init-users
# UBTU-22-651015
aideinit








