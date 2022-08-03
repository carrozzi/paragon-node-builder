#!/usr/bin/env bash
set -x
subscription-manager register --username=***REMOVED*** --password=***REMOVED*** --auto-attach
echo "vm.max_map_count=262144" >> /etc/sysctl.conf
echo "net.bridge.bridge-nf-call-iptables=1" >> /etc/sysctl.conf
echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> /root/.bashrc
echo "alias k9s='docker run --rm -it -v /etc/kubernetes/admin.conf:/root/.kube/config quay.io/derailed/k9s'" >> /root/.bashrc
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
yum -y install wget fuse-libs open-vm-tools
setenforce 0
yum install -y yum-utils device-mapper-persistent-data lvm2 python3 nmap-ncat
dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum -y install wireshark-cli jq python3-pyyaml
yum -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
yum -y install bash-completion gdisk iptables openssl rsync

systemctl start docker
systemctl enable docker
groupadd docker
usermod -aG docker paragon
bash -c "$(curl -sL https://get-gnmic.kmrd.dev)"
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
sed -i "s/enabled.*=.*1/enabled=0/" /etc/yum.repos.d/*.repo
echo docker_version: \'$(yum list docker-ce --showduplicates -q| awk '/docker/{print $2}'| sed 's/.*:\(.*\)\.el8/\1/')\' >> /tmp/config.txt
echo containerd_version_redhat: \'$(yum list containerd.io --showduplicates -q| awk '/container/{print $2}'| sed 's/\(.*\)\.el8/\1/')\' >> /tmp/config.txt



