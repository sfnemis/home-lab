#!/bin/bash

# Ana dizin
BASE_DIR=$(pwd)

# Ana .env dosyasını yükle
set -a
source .env
set +a

# Docker ağını oluştur
echo "Docker ağı oluşturuluyor..."
docker network create --subnet=$DOCKER_NETWORK_SUBNET $DOCKER_NETWORK || echo "Ağ zaten var."

# Gerekli dizinleri oluştur
mkdir -p traefik/config/dynamic traefik/config/acme traefik/logs
mkdir -p crowdsec/config crowdsec/data
mkdir -p cloudflare-tunnel/config
mkdir -p authentik/config
mkdir -p portainer/data/secrets

# CrowdSec API anahtarı zaten tanımlanmış mı kontrol et
if [ -z "$CROWDSEC_API_KEY" ] || [ "$CROWDSEC_API_KEY" = "change-me-to-secure-key" ]; then
    echo "CrowdSec API anahtarı henüz oluşturulmamış. İlk aşama kurulumu başlatılıyor..."
    
    # İlk olarak sadece CrowdSec'i başlat (bouncer olmadan)
    echo "CrowdSec başlatılıyor..."
    cd $BASE_DIR/crowdsec
    # Geçici olarak bouncer servisini devre dışı bırakmış bir yaml dosyası oluşturalım
    cat docker-compose.yml | grep -v "bouncer:" -A 10 | grep -v "depends_on:" -A 2 > docker-compose-temp.yml
    docker-compose -f docker-compose-temp.yml up -d
    sleep 10
    
    # API anahtarını oluştur
    echo "CrowdSec API anahtarı oluşturuluyor..."
    BOUNCER_KEY=$(docker exec crowdsec cscli bouncers add traefik-bouncer -o raw)
    
    if [ -z "$BOUNCER_KEY" ]; then
        echo "HATA: CrowdSec API anahtarı oluşturulamadı!"
        exit 1
    fi
    
    # Ana .env dosyasını güncelle
    echo "API anahtarı .env dosyasına ekleniyor..."
    sed -i "s|CROWDSEC_API_KEY=.*|CROWDSEC_API_KEY=$BOUNCER_KEY|" .env
    
    # CrowdSec'i durdur
    echo "Geçici CrowdSec durduruluyor..."
    docker-compose -f docker-compose-temp.yml down
    rm docker-compose-temp.yml
    
    # .env dosyasını yeniden yükle
    set -a
    source .env
    set +a
    
    echo "CrowdSec API anahtarı başarıyla oluşturuldu: $BOUNCER_KEY"
fi

# .env dosyalarını kopyala
echo "Servis-spesifik .env dosyaları hazırlanıyor..."
for service in traefik crowdsec cloudflare-tunnel authentik portainer watchtower; do
    envsubst < ${service}/.env.template > ${service}/.env
done

# Portainer admin şifresini oluştur
echo "Portainer için admin şifresini oluşturuluyor..."
mkdir -p portainer/data/secrets
echo -n "$PORTAINER_ADMIN_PASSWORD" > portainer/data/secrets/admin-password.txt

# Servisleri başlat
echo "Servisler başlatılıyor..."

# Önce Traefik'i başlat
echo "1/6: Traefik başlatılıyor..."
cd $BASE_DIR/traefik
docker-compose up -d
sleep 10

# CrowdSec'i başlat
echo "2/6: CrowdSec başlatılıyor..."
cd $BASE_DIR/crowdsec
docker-compose up -d
sleep 5

# Cloudflare Tunnel'ı başlat
echo "3/6: Cloudflare Tunnel başlatılıyor..."
cd $BASE_DIR/cloudflare-tunnel
docker-compose up -d
sleep 5

# Authentik'i başlat
echo "4/6: Authentik başlatılıyor..."
cd $BASE_DIR/authentik
docker-compose up -d
sleep 10

# Portainer'ı başlat
echo "5/6: Portainer başlatılıyor..."
cd $BASE_DIR/portainer
docker-compose up -d
sleep 5

# Watchtower'ı başlat
echo "6/6: Watchtower başlatılıyor..."
cd $BASE_DIR/watchtower
docker-compose up -d

# Durum kontrolü
echo "Tüm servisler başlatıldı. Durum kontrolü yapılıyor..."
cd $BASE_DIR
docker ps

echo "Kurulum tamamlandı!"
echo "Authentik: https://auth.${ROOT_DOMAIN}"
echo "Traefik Dashboard: https://traefik.${ROOT_DOMAIN}"
echo "Portainer: https://portainer.${ROOT_DOMAIN}"