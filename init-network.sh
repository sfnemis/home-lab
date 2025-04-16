#!/bin/bash

# Ana .env dosyasını yükle
set -a
source .env
set +a

# Docker ağını oluştur
echo "Docker ağı oluşturuluyor: $DOCKER_NETWORK"
docker network create --subnet=$DOCKER_NETWORK_SUBNET $DOCKER_NETWORK || echo "Ağ zaten var ya da oluşturulamadı."

echo "Docker ağı hazır."
docker network inspect $DOCKER_NETWORK