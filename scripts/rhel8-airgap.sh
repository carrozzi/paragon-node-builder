#!/usr/bin/env bash
set -x
subscription-manager register --username=USERNAME --password=PASSWORD --auto-attach
echo "vm.max_map_count=262144" >> /etc/sysctl.conf
echo "net.bridge.bridge-nf-call-iptables=1" >> /etc/sysctl.conf
echo "export KUBECONFIG=/etc/kubernetes/admin.conf" >> /root/.bashrc
echo "alias k9s='docker run --rm -it -v /etc/kubernetes/admin.conf:/root/.kube/config quay.io/derailed/k9s'" >> /root/.bashrc
echo "iptables -A OUTPUT --dst=10.0.0.0/8 -j ACCEPT" >> /root/.bashrc
echo "iptables -A OUTPUT --dst=172.16.0.0/12 -j ACCEPT" >> /root/.bashrc
echo "iptables -A OUTPUT --dst=192.168.0.0/16 -j ACCEPT" >> /root/.bashrc
echo "iptables -A OUTPUT --dst=127.0.0.1 -j ACCEPT" >> /root/.bashrc
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
yum -y install wget fuse-libs open-vm-tools
yum -y install fuse3-libs policycoreutils-python-utils
setenforce 0
#yum install -y yum-utils device-mapper-persistent-data lvm2 python3 nmap-ncat
#dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum -y install wireshark-cli jq python3-pyyaml
#yum -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
#yum -y install bash-completion gdisk iptables openssl rsync python-six PyYAML
cd /tmp
tar xvf Paragon_23.1.tar.gz
rm Paragon_23.1.tar.gz
cd Paragon_23.1
chmod 755 run
mkdir root
cd root
tar zxvf ../rhel-84-airgap.tar.gz
rpm -ihv --force *
systemctl start docker
systemctl enable docker
groupadd docker
usermod -aG docker paragon
bash -c "$(curl -sL https://get-gnmic.kmrd.dev)"
#yum install -y kubectl-1.21.2-0.x86_64 kubelet-1.21.2-0.x86_64 kubeadm-1.21.2-0.x86_64
docker pull quay.io/derailed/k9s
#wget https://get.helm.sh/helm-v3.4.0-linux-amd64.tar.gz -O /tmp/helm.tgz
#mkdir /usr/local/bin/helm-v3.4.0
#tar zxf /tmp/helm.tgz -C /usr/local/bin/helm-v3.4.0
#ln -s /usr/local/bin/helm-v3.4.0/linux-amd64/helm /usr/local/bin/helm
sed -i "s/enabled.*=.*1/enabled=0/" /etc/yum.repos.d/*.repo
printf '\n' >> /tmp/config.txt
echo docker_version: \'$(yum list docker-ce --showduplicates -q| awk '/docker/{print $2}'| sed 's/.*:\(.*\)\.el8/\1/')\' >> /tmp/config.txt
echo containerd_version_redhat: \'$(yum list containerd.io --showduplicates -q| awk '/container/{print $2}'| sed 's/\(.*\)\.el8/\1/')\' >> /tmp/config.txt
cd /tmp
cd Paragon_23.1
./run -c lab init
cat ../config.txt >> lab/config.yml
rm /etc/sysconfig/network-scripts/ifcfg-ens*
cp /tmp/ifcfg* /etc/sysconfig/network-scripts
subscription-manager remove --all
subscription-manager unregister
subscription-manager clean




