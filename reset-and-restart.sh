#!/bin/bash

# Ana dizin
BASE_DIR=$(pwd)

echo "Tüm Docker konteynerlerini ve networklerini temizliyoruz..."

# Tüm konteynerları durdur ve sil
docker rm -f $(docker ps -a -q)

# Kullanılmayan ağları temizle
docker network prune -f

# Docker ağını yeniden oluştur
echo "Docker ağını oluşturuyoruz..."
docker network create --subnet=172.18.0.0/16 proxy

echo "Servisleri sırasıyla başlatıyoruz..."

# Traefik'i başlat
echo "1. Traefik başlatılıyor..."
cd $BASE_DIR/traefik
docker-compose up -d
sleep 10

# CrowdSec'i başlat
echo "2. CrowdSec başlatılıyor..."
cd $BASE_DIR/crowdsec
docker-compose up -d
sleep 5

# Cloudflare Tunnel'ı başlat
echo "3. Cloudflare Tunnel başlatılıyor..."
cd $BASE_DIR/cloudflare-tunnel
docker-compose up -d
sleep 5

# Authentik'i başlat
echo "4. Authentik başlatılıyor..."
cd $BASE_DIR/authentik
docker-compose up -d
sleep 5

# Portainer'ı başlat
echo "5. Portainer başlatılıyor..."
cd $BASE_DIR/portainer
docker-compose up -d
sleep 5

# Watchtower'ı başlat
echo "6. Watchtower başlatılıyor..."
cd $BASE_DIR/watchtower
docker-compose up -d

echo "Tüm servisler yeniden başlatıldı."
echo "Konteyner durumları:"
docker ps
echo "----------------------------------"
echo "Hizmetlerinize şuradan erişebilirsiniz:"
echo "Traefik Dashboard: https://traefik.ofhome.cloud"
echo "Portainer: https://portainer.ofhome.cloud"
echo "Authentik: https://auth.ofhome.cloud"