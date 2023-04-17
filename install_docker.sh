#!/bin/bash

#Install Git
yum install -y git
# Install Docker
yum update -y
yum install -y docker
systemctl start docker
systemctl enable docker

# Install Docker Compose
sudo curl -L https://github.com/docker/compose/releases/download/1.21.0/docker-compose-`uname -s`-`uname -m` | sudo tee /usr/local/bin/docker-compose > /dev/null
sudo chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
