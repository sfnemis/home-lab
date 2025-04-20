#!/bin/bash

# Ana dizin
BASE_DIR=$(pwd)

echo "Servisleri yeniden başlatıyoruz..."

# Önce tüm servisleri durdur
echo "Tüm servisleri durduruyoruz..."
cd $BASE_DIR/watchtower
docker-compose down
cd $BASE_DIR/portainer
docker-compose down
cd $BASE_DIR/authentik
docker-compose down
cd $BASE_DIR/cloudflare-tunnel
docker-compose down
cd $BASE_DIR/crowdsec
docker-compose down
cd $BASE_DIR/traefik
docker-compose down

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
echo "Hizmetlerinize şuradan erişebilirsiniz:"
echo "Traefik Dashboard: https://traefik.ofhome.cloud"
echo "Portainer: https://portainer.ofhome.cloud"
echo "Authentik: https://auth.ofhome.cloud"