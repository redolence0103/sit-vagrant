
# Vagrantfile and Scripts to Automate Kubernetes Setup using Kubeadm [Practice Environemnt for CKA/CKAD and CKS Exams]

## Documentation

Current k8s version for CKA, CKAD and CKS exam: 1.22.

Refer this link for documentation: https://devopscube.com/kubernetes-cluster-vagrant/

## CKA, CKAD, CKS or KCNA Voucher Codes

🚀  If you are preparing for CKA, CKAD, CKS or KCNA exam, save 25% (up to $143) using code **CNYDEVOPS22** at https://kube.promo/cny

## Prerequisites

1. Working Vagrant setup
2. 8 Gig + RAM workstation as the Vms use 3 vCPUS and 4+ GB RAM

## For MAC Users

Latest version of Virtualbox for Mac/Linux can cause issues because you have to create/edit the /etc/vbox/networks.conf file and add:
<pre>* 0.0.0.0/0 ::/0</pre>

So that the host only networks can be in any range, not just 192.168.56.0/21 as described here:
https://discuss.hashicorp.com/t/vagrant-2-2-18-osx-11-6-cannot-create-private-network/30984/23
 
## Usage/Examples

To provision the cluster, execute the following commands.

```shell
git clone https://github.com/scriptcamp/vagrant-kubeadm-kubernetes.git
cd vagrant-kubeadm-kubernetes
vagrant up
```

## Set Kubeconfig file varaible.

```shell
cd vagrant-kubeadm-kubernetes
cd configs
export KUBECONFIG=$(pwd)/config
```

or you can copy the config file to .kube directory.

```shell
cp config ~/.kube/
```

## Kubernetes Dashboard URL

```shell
http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/overview?namespace=kubernetes-dashboard
```

## Kubernetes login token

Vagrant up will create the admin user token and saves in the configs directory.

```shell
cd vagrant-kubeadm-kubernetes
cd configs
cat token
```

## To shutdown the cluster, 

```shell
vagrant halt
```

## To restart the cluster,

```shell
vagrant up
```

## To destroy the cluster, 

```shell
vagrant destroy -f
```

## Centos & HA based Setup

If you want Centos based setup, please refer https://github.com/marthanda93/VAAS
  
## Disk ad-on
PS C:\Users\Administrator> Get-ChildItem Env:
PS C:\Users\Administrator> [Environment]::SetEnvironmentVariable('VAGRANT_EXPERIMENTAL','disks','User')

      node.vm.disk :disk, size: "30GB", name: "extra_storage1"
PS C:\Users\Administrator> vagrant reload

## helm 
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add influxdata https://helm.influxdata.com
helm repo add grafana https://grafana.github.io/helm-charts
helm install kafka bitnami/kafka --namespace kafka --create-namespace

## root Disk space resize
ls /sys/class/scsi_device/
echo 1 > /sys/class/scsi_device/2\:0\:0\:0/device/rescan
cfdisk
parted

lvextend -l +100%FREE /dev/mapper/ubuntu--vg-ubuntu--lv
resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv

## default StorageClass
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

## code server
curl -fsSL https://code-server.dev/install.sh | sh
sudo systemctl enable --now code-server@$USER

## maven
As of 2021/10/25, maven 3.6.x is not supporting Java 17
Create vi ~/.mavenrc file and give any version lower than 17.

wget https://dlcdn.apache.org/maven/maven-3/3.8.4/binaries/apache-maven-3.8.4-bin.tar.gz
sudo mkdir -p /usr/local/apache-maven
sudo mv apache-maven-3.8.4-bin.tar.gz /usr/local/apache-maven
cd /usr/local/apache-maven
sudo tar -xzvf apache-maven-3.8.4-bin.tar.gz

Edit ~/.profile

export M2_HOME=/usr/local/apache-maven/apache-maven-3.8.4
export M2=$M2_HOME/bin
export MAVEN_OPTS="-Xms256m -Xmx512m"
export PATH=$M2:$PAT

## download kubectl for windows 10
https://storage.googleapis.com/kubernetes-release/release/v1.23.0/bin/windows/amd64/kubectl.exe

## date
date -d  '2022-01-01T03:00:00Z' +"%s%N"
date --date='@1643550000'