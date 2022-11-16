#! /bin/sh

sudo apt update
sudo apt install openjdk-11-jre

curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install jenkins

# GitHub Pull Request Builder
# blue ocean
# Mask Passwords
# Embeddable Build Status

sudo apt-get install -y git build-essential software-properties-common tmux vim iproute2 tcpdump iptables net-tools iputils-ping ipvsadm netcat wget ethtool nftables htop

# Golang
# https://go.dev/doc/install
wget https://go.dev/dl/go1.19.1.linux-arm64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.19.1.linux-arm64.tar.gz
sudo bash -c 'echo "export PATH=\$PATH:/usr/local/go/bin" >> /etc/profile'
echo "export PATH=\$PATH:\$(go env GOPATH)/bin" >> /etc/profile

# Docker
# https://docs.docker.com/engine/install/ubuntu/
sudo apt-get update
sudo apt-get install -y ca-certificates
sudo apt-get install -y curl
sudo apt-get install -y gnupg
sudo apt-get install -y lsb-release
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get -y update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin
# https://docs.docker.com/engine/install/linux-postinstall/
sudo groupadd docker
sudo usermod -aG docker $USER