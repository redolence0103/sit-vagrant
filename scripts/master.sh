#! /bin/bash

MASTER_IP="10.0.0.10"
NODENAME=$(hostname -s)
POD_CIDR="192.168.0.0/16"

sudo kubeadm config images pull

echo "Preflight Check Passed: Downloaded All Required Images"


sudo kubeadm init --apiserver-advertise-address=$MASTER_IP  --apiserver-cert-extra-sans=$MASTER_IP --pod-network-cidr=$POD_CIDR --node-name $NODENAME --ignore-preflight-errors Swap

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Save Configs to shared /Vagrant location

# For Vagrant re-runs, check if there is existing configs in the location and delete it for saving new configuration.

config_path="/vagrant/configs"

if [ -d $config_path ]; then
   rm -f $config_path/*
else
   mkdir -p /vagrant/configs
fi

cp -i /etc/kubernetes/admin.conf /vagrant/configs/config
touch /vagrant/configs/join.sh
chmod +x /vagrant/configs/join.sh       


kubeadm token create --print-join-command > /vagrant/configs/join.sh

# Install Calico Network Plugin

curl https://docs.projectcalico.org/manifests/calico.yaml -O

kubectl apply -f calico.yaml

# Install Metrics Server

kubectl apply -f https://raw.githubusercontent.com/scriptcamp/kubeadm-scripts/main/manifests/metrics-server.yaml

# Install Kubernetes Dashboard

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml


# Create Dashboard User

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
EOF

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF


kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}" >> /vagrant/configs/token
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

sudo -i -u vagrant bash << EOF
mkdir -p /home/vagrant/.kube
sudo cp -i /vagrant/configs/config /home/vagrant/.kube/
sudo chmod 600 /home/vagrant/.kube/config
sudo chown 1000:1000 /home/vagrant/.kube/config
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 > /home/vagrant/get_helm.sh
chmod 700 /home/vagrant/get_helm.sh

curl -fsSL https://code-server.dev/install.sh | sh
sudo systemctl enable --now code-server@$USER

sudo lvextend -l +100%FREE /dev/mapper/ubuntu--vg-ubuntu--lv
sudo resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv

sudo /home/vagrant/get_helm.sh
helm repo add stable https://charts.bitnami.com/bitnami
helm repo add influxdata https://helm.influxdata.com
helm repo add grafana https://grafana.github.io/helm-charts
helm install kafka bitnami/kafka --namespace kafka --create-namespace
EOF

sudo apt-get update

sudo apt install openjdk-17-jdk openjdk-17-jre -y

sudo -i -u vagrant bash << EOF
wget https://dlcdn.apache.org/maven/maven-3/3.8.4/binaries/apache-maven-3.8.4-bin.tar.gz
sudo mkdir -p /usr/local/apache-maven
sudo mv apache-maven-3.8.4-bin.tar.gz /usr/local/apache-maven
cd /usr/local/apache-maven
sudo tar -xzf apache-maven-3.8.4-bin.tar.gz
EOF

sudo apt install nodejs -y

sudo apt install npm -y

sudo apt install bash-completion -y

cat <<EOF | tee -a /home/vagrant/.bashrc
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export M2_HOME=/usr/local/apache-maven/apache-maven-3.8.4
export M2=$M2_HOME/bin
export MAVEN_OPTS="-Xms256m -Xmx512m"
export PATH=$M2:$JAVA_HOME/bin:$PATH
source <(kubectl completion bash)
EOF

cat <<EOF | tee -a /home/vagrant/.mavenrc
JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
EOF

cat <<EOF | tee /home/vagrant/kafka.txt
kafka-console-producer.sh \
  --broker-list kafka-0.kafka-headless.kafka.svc.cluster.local:9092 \
  --topic test
kafka-console-consumer.sh \
  --bootstrap-server kafka.kafka.svc.cluster.local:9092 \
  --topic test --from-beginning
EOF