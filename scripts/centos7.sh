#!/usr/bin/env bash
set -x
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> /root/.bashrc
echo "alias k9s='docker run --rm -it -v /etc/kubernetes/admin.conf:/root/.kube/config quay.io/derailed/k9s'" >> /root/.bashrc
rm /etc/sysconfig/network-scripts/ifcfg-ens*
cp /tmp/ifcfg* /etc/sysconfig/network-scripts
systemctl restart network
yum -y update
yum -y install epel-release yum-utils wget fuse-libs open-vm-tools
setenforce 0
yum install -y yum-utils device-mapper-persistent-data lvm2 python3 nmap-ncat
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum -y install docker-ce docker-ce-cli containerd.io wireshark jq htop vim-enhanced
yum -y install bash-completion gdisk iptables python-six openssl chrony rsync
systemctl start docker
systemctl enable docker
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
rpm -Uvh https://www.elrepo.org/elrepo-release-7.0-5.el7.elrepo.noarch.rpm
yum -y --enablerepo=elrepo-kernel install kernel-lt
sed -i "s/GRUB_DEFAULT=saved/GRUB_DEFAULT=0/" /etc/default/grub
grub2-mkconfig -o /boot/grub2/grub.cfg
bash -c "$(curl -sL https://get-gnmic.kmrd.dev)"
mkdir /cdrom
mv /tmp/repodata /cdrom/
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
yum install -y kubectl-1.21.2-0.x86_64 kubelet-1.21.2-0.x86_64 kubeadm-1.21.2-0.x86_64
docker pull quay.io/derailed/k9s
wget https://get.helm.sh/helm-v3.4.0-linux-amd64.tar.gz -O /tmp/helm.tgz
mkdir /usr/local/bin/helm-v3.4.0
tar zxf /tmp/helm.tgz -C /usr/local/bin/helm-v3.4.0
ln -s /usr/local/bin/helm-v3.4.0/linux-amd64/helm /usr/local/bin/helm
mv /etc/yum.repos.d/*.repo /tmp
mv /tmp/local.repo /etc/yum.repos.d
echo docker_version: \'$(yum list docker-ce --showduplicates -q| awk '/docker/{print $2}'| sed 's/.*:\(.*\)\.el7/\1/')\' >> /tmp/config.txt
echo containerd_version_redhat: \'$(yum list containerd.io --showduplicates -q| awk '/container/{print $2}'| sed 's/\(.*\)\.el7/\1/')\' >> /tmp/config.txt
cd /tmp
tar xvf Paragon22.1.tar.gz
tar xvf Paragon_22.1_SP2.tar.gz
rm *.tar.gz
cd Paragon22.1
chmod 755 run
./run -c lab init
cp ../config.yml lab
cp ../inventory lab
cat ../config.txt >> lab/config.yml



