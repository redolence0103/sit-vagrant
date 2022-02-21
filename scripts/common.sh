#! /bin/bash

# Variable Declaration

KUBERNETES_VERSION="1.22.6-00"

# disable swap 
sudo swapoff -a
# keeps the swaf off during reboot
# sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
sudo sed -i 's/\/swap/#swap/' /etc/fstab

sudo apt-get install -y \
    curl \
    lsb-release

# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# echo \
#  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
#  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update -y
sudo apt-get install docker.io -y

# Following configurations are recomended in the kubenetes documentation for Docker runtime. Please refer https://kubernetes.io/docs/setup/production-environment/container-runtimes/#docker

cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF

sudo systemctl enable docker
sudo systemctl daemon-reload
sudo systemctl restart docker
sudo usermod -aG docker vagrant
echo "Docker Runtime Configured Successfully"

#####################download Start
wget --no-check-certificate https://packages.cloud.google.com/apt/pool/cri-tools_1.13.0-01_amd64_4ff4588f5589826775f4a3bebd95aec5b9fb591ba8fb89a62845ffa8efe8cf22.deb
wget --no-check-certificate https://packages.cloud.google.com/apt/pool/kubeadm_1.20.1-00_amd64_7cd8d4021bb251862b755ed9c240091a532b89e6c796d58c3fdea7c9a72b878f.deb
wget --no-check-certificate https://packages.cloud.google.com/apt/pool/kubectl_1.20.1-00_amd64_b927311062e6a4610d9ac3bc8560457ab23fbd697a3052c394a1d7cc9e46a17d.deb
wget --no-check-certificate https://packages.cloud.google.com/apt/pool/kubelet_1.20.1-00_amd64_560a52294b8b339e0ca8ddbc480218e93ebb01daef0446887803815bcd0c41eb.deb
wget --no-check-certificate https://packages.cloud.google.com/apt/pool/kubernetes-cni_0.8.7-00_amd64_ca2303ea0eecadf379c65bad855f9ad7c95c16502c0e7b3d50edcb53403c500f.deb


sudo apt-get install socat conntrack ebtables
sudo dpkg --install ./kubernetes-cni_0.8.7-00_amd64_ca2303ea0eecadf379c65bad855f9ad7c95c16502c0e7b3d50edcb53403c500f.deb
sudo dpkg --install ./kubelet_1.20.1-00_amd64_560a52294b8b339e0ca8ddbc480218e93ebb01daef0446887803815bcd0c41eb.deb
sudo dpkg --install ./cri-tools_1.13.0-01_amd64_4ff4588f5589826775f4a3bebd95aec5b9fb591ba8fb89a62845ffa8efe8cf22.deb
sudo dpkg --install ./kubectl_1.20.1-00_amd64_b927311062e6a4610d9ac3bc8560457ab23fbd697a3052c394a1d7cc9e46a17d.deb
sudo dpkg --install ./kubeadm_1.20.1-00_amd64_7cd8d4021bb251862b755ed9c240091a532b89e6c796d58c3fdea7c9a72b878f.deb
#####################download End


sudo apt-mark hold kubelet kubeadm kubectl
