#!/bin/bash
set -e

IP=$1
DIR="/home/ubuntu/app"
IMAGE="anitodevops/app-image:latest"

#Transfering docker-compose.yml file to Application Server
scp -i newtestkey.pem docker-compose.yml ubuntu@${IP}:/home/ubuntu/docker-compose.yml

ssh -i newtestkey.pem ubuntu@${IP} << EOF
  set -e
  
  mkdir -p ${DIR}
  cd ${DIR}
  mv /home/ubuntu/docker-compose.yml ${DIR}/
  
  #Installing Docker & Docker-compose packages
  echo "Insatlling Packages..Please wait.."
  sudo apt update >>/tmp/pkg_update.log 
  sudo apt install -y docker.io docker-compose >>/tmp/pkg_install.log

  #Pull Docker images from Registry
  sudo docker pull anitodevops/app-image:latest >>/tmp/dckr_img_pull.log

  #runs the App container 
  sudo docker-compose up -d --remove-orphans
  
  echo "Application has been Successfully Deployed!"
EOF

