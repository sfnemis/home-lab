# Cloudflare Tunnel, Traefik, CrowdSec ve Authentik Docker Compose Kurulumu

Bu proje, Cloudflare Tunnel, Traefik, CrowdSec, Authentik ve Portainer Business Edition'ı tek bir Docker Compose ortamında çalıştırmak için gereken tüm dosyaları içerir. Bu ortam, *.ofhome.cloud alan adları için güvenli ve otomatik bir altyapı sağlar.

## Özellikler

- **Traefik v3.3.5**: Reverse proxy olarak çalışır ve dinamik olarak yeni eklenen uygulamaları otomatik olarak yapılandırır.
- **CrowdSec v1.6.8**: Güvenlik tehditlerine karşı koruma sağlar ve Traefik ile entegre çalışır.
- **Cloudflare Tunnel**: Sunucunuzu internet üzerinden güvenli bir şekilde erişilebilir hale getirir.
- **Authentik**: Kimlik doğrulama ve yetkilendirme için merkezi bir sistem sunar.
- **Portainer Business Edition**: Docker konteynerlerinizi kolayca yönetmenizi sağlar.
- **Watchtower**: Konteynerlerinizin güncel kalmasını sağlar.

## Kurulum Gereksinimleri

- Docker ve Docker Compose yüklü bir sunucu
- Cloudflare hesabı ve bir kayıtlı alan adı
- Cloudflare API anahtarı ve e-posta adresi
- Cloudflare Tunnel token'ı

## Kurulum Adımları

1. Ana `.env` dosyasını düzenleyin:

```bash
nano .env
```

2. Aşağıdaki değerleri kendi bilgilerinizle güncelleyin:

- `DOMAIN`: Ana alan adınız (örn. ofhome.cloud)
- `CLOUDFLARE_EMAIL`: Cloudflare e-posta adresiniz
- `CLOUDFLARE_API_KEY`: Cloudflare API anahtarınız
- `CLOUDFLARE_TUNNEL_TOKEN`: Cloudflare Tunnel token'ınız
- `AUTHENTIK_SECRET_KEY`: Authentik için güvenli bir anahtar
- `AUTHENTIK_POSTGRES_PASSWORD`: Authentik veritabanı için güvenli bir şifre
- `CROWDSEC_API_KEY`: CrowdSec API anahtarı
- `PORTAINER_ADMIN_PASSWORD`: Portainer admin şifresi

3. Network oluşturma ve kurulum betiğini çalıştırın:

```bash
chmod +x init-network.sh setup.sh restart.sh
./init-network.sh
./setup.sh
```

## Yapılandırma

### Yeni Bir Uygulama Ekleme

Yeni bir uygulama eklemek için, docker-compose.yml dosyanıza Traefik etiketlerini eklemeniz yeterlidir:

```yaml
services:
  myapp:
    image: myapp:latest
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.myapp.rule=Host(`myapp.${ROOT_DOMAIN}`)"
      - "traefik.http.routers.myapp.entrypoints=websecure"
      - "traefik.http.routers.myapp.tls=true"
      - "traefik.http.routers.myapp.tls.certresolver=cloudflare"
      - "traefik.http.routers.myapp.middlewares=crowdsec-bouncer"
      - "traefik.http.services.myapp.loadbalancer.server.port=8080"
```

### Authentik ile Kimlik Doğrulama Ekleme

Bir uygulamaya Authentik ile kimlik doğrulama eklemek için:

```yaml
labels:
  - "traefik.http.routers.myapp.middlewares=authentik-outpost@docker"
```

## Servis Portları

- Traefik: 80, 443, 8080 (Dashboard)
- CrowdSec: 6060 (LAPI - sadece dahili)
- Authentik: 9000
- Portainer: 9001 (Authentik ile port çakışmasını önlemek için değiştirildi)

## Güvenlik Notları

- Bu yapılandırmada tüm dış trafiğin Cloudflare Tunnel üzerinden geçmesi ve hiçbir portun doğrudan internete açık olmaması önerilir.
- `.env` dosyalarındaki tüm şifreleri ve API anahtarlarını güçlü ve benzersiz değerlerle değiştirin.
- CrowdSec yapılandırmasını kendi ihtiyaçlarınıza göre özelleştirin.

## Bakım

### Güncellemeler

Watchtower, konteynerleri otomatik olarak güncelleyecektir. Varsayılan olarak, her gün saat 04:00'te çalışır. Bu ayarı watchtower/.env dosyasından değiştirebilirsiniz.

### Servis Yönetimi

Tüm servisleri yeniden başlatmak için:

```bash
./restart.sh
```

## Sorun Giderme

### Logları Kontrol Etme

```bash
# Traefik logları
docker logs traefik

# CrowdSec logları
docker logs crowdsec

# Authentik logları
docker logs authentik-server
```

### Ağ Bağlantılarını Kontrol Etme

```bash
# Docker ağını görüntüle
docker network inspect proxy
```

## İmaj Referansları

Bu projede kullanılan Docker imajları aşağıdaki resmi kaynaklardan alınmıştır:

- Traefik: [traefik:v3.3.5](https://hub.docker.com/_/traefik)
- CrowdSec: [crowdsecurity/crowdsec:v1.6.8](https://hub.docker.com/r/crowdsecurity/crowdsec)
- CrowdSec Bouncer: [maxlerebourg/crowdsec-bouncer-traefik-plugin:v1.4.2](https://github.com/maxlerebourg/crowdsec-bouncer-traefik-plugin)
- Cloudflare Tunnel: [cloudflare/cloudflared:2025.4.0](https://hub.docker.com/r/cloudflare/cloudflared)
- Authentik: [ghcr.io/goauthentik/server:2025.2.4](https://github.com/goauthentik/authentik)
- Portainer: [portainer/portainer-ee:2.19.4](https://hub.docker.com/r/portainer/portainer-ee)
- Watchtower: [containrrr/watchtower:1.7.1](https://hub.docker.com/r/containrrr/watchtower)
- PostgreSQL: [postgres:16-alpine](https://hub.docker.com/_/postgres)
- Redis: [redis:7-alpine](https://hub.docker.com/_/redis)