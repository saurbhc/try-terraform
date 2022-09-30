#!/bin/bash
sudo apt update && \
sudo apt -y install curl nginx uidmap && \
sudo systemctl start nginx.service && \
sudo systemctl status nginx.service && \
curl -fsSL https://get.docker.com -o get-docker.sh && \
sudo sh ./get-docker.sh && \
sudo apt -y install docker-ce-rootless-extras && \
docker run hello-world && \
sudo usermod -aG docker ubuntu && \
newgrp docker && \
echo "user_data Script Worked!" >> /home/ubuntu/.output_user_data.log