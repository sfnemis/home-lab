#!/bin/bash

# Ana dizin
BASE_DIR=$(pwd)

# Ana .env dosyasını yükle
set -a
source .env
set +a

# Servisleri yeniden başlat
echo "Servisler yeniden başlatılıyor..."

# Önce Watchtower'ı durdur
echo "1/12: Watchtower durduruluyor..."
cd $BASE_DIR/watchtower
docker-compose down
sleep 2

# Portainer'ı durdur
echo "2/12: Portainer durduruluyor..."
cd $BASE_DIR/portainer
docker-compose down
sleep 2

# Authentik'i durdur
echo "3/12: Authentik durduruluyor..."
cd $BASE_DIR/authentik
docker-compose down
sleep 2

# Cloudflare Tunnel'ı durdur
echo "4/12: Cloudflare Tunnel durduruluyor..."
cd $BASE_DIR/cloudflare-tunnel
docker-compose down
sleep 2

# CrowdSec'i durdur
echo "5/12: CrowdSec durduruluyor..."
cd $BASE_DIR/crowdsec
docker-compose down
sleep 2

# Traefik'i durdur
echo "6/12: Traefik durduruluyor..."
cd $BASE_DIR/traefik
docker-compose down
sleep 2

# Şimdi ters sırayla başlat
# Traefik'i başlat
echo "7/12: Traefik başlatılıyor..."
cd $BASE_DIR/traefik
docker-compose up -d
sleep 10

# CrowdSec'i başlat
echo "8/12: CrowdSec başlatılıyor..."
cd $BASE_DIR/crowdsec
docker-compose up -d
sleep 5

# Cloudflare Tunnel'ı başlat
echo "9/12: Cloudflare Tunnel başlatılıyor..."
cd $BASE_DIR/cloudflare-tunnel
docker-compose up -d
sleep 5

# Authentik'i başlat
echo "10/12: Authentik başlatılıyor..."
cd $BASE_DIR/authentik
docker-compose up -d
sleep 10

# Portainer'ı başlat
echo "11/12: Portainer başlatılıyor..."
cd $BASE_DIR/portainer
docker-compose up -d
sleep 5

# Watchtower'ı başlat
echo "12/12: Watchtower başlatılıyor..."
cd $BASE_DIR/watchtower
docker-compose up -d

# Durum kontrolü
echo "Tüm servisler yeniden başlatıldı. Durum kontrolü yapılıyor..."
cd $BASE_DIR
docker ps

echo "Yeniden başlatma tamamlandı!"
echo "Authentik: https://auth.${ROOT_DOMAIN}"
echo "Traefik Dashboard: https://traefik.${ROOT_DOMAIN}"
echo "Portainer: https://portainer.${ROOT_DOMAIN}"