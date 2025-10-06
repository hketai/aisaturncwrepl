#!/bin/bash
# Digital Ocean Sunucu Kurulum Script'i
# Bu script'i sunucuda bir kez çalıştırın

set -e

echo "🚀 Chatwoot Production Kurulumu Başlıyor..."
echo "============================================"

# Sistem güncellemeleri
echo "📦 Sistem paketleri güncelleniyor..."
sudo apt-get update
sudo apt-get upgrade -y

# Gerekli sistem paketleri
echo "📦 Gerekli paketler kuruluyor..."
sudo apt-get install -y curl git build-essential libssl-dev libpq-dev \
    postgresql postgresql-contrib redis-server nginx certbot python3-certbot-nginx

# Ruby kurulumu (rbenv ile)
echo "💎 Ruby kuruluyor..."
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc

rbenv install 3.2.2
rbenv global 3.2.2

# Node.js kurulumu
echo "📦 Node.js kuruluyor..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# pnpm kurulumu
echo "📦 pnpm kuruluyor..."
npm install -g pnpm

# PostgreSQL yapılandırması
echo "🗄️  PostgreSQL yapılandırılıyor..."
sudo -u postgres psql << EOF
CREATE USER chatwoot WITH PASSWORD 'CHANGE_THIS_PASSWORD';
CREATE DATABASE chatwoot_production OWNER chatwoot;
GRANT ALL PRIVILEGES ON DATABASE chatwoot_production TO chatwoot;
EOF

# Uygulama dizini oluşturma
echo "📁 Uygulama dizini oluşturuluyor..."
sudo mkdir -p /var/www/chatwoot
sudo chown $USER:$USER /var/www/chatwoot

# Repository'yi klonlama
echo "📥 Repository klonlanıyor..."
cd /var/www
git clone https://github.com/GITHUB_USERNAME/REPOSITORY_NAME.git chatwoot
cd chatwoot

# Bundle kurulumu
echo "💎 Ruby gems kuruluyor..."
gem install bundler
bundle install --deployment --without development test

# Node paketleri kurulumu
echo "📦 Node paketleri kuruluyor..."
pnpm install --frozen-lockfile

# Environment dosyası oluşturma
echo "⚙️  Environment dosyası oluşturuluyor..."
cat > .env.production << 'ENVFILE'
POSTGRES_HOST=localhost
POSTGRES_USERNAME=chatwoot
POSTGRES_PASSWORD=CHANGE_THIS_PASSWORD
POSTGRES_DATABASE=chatwoot_production
POSTGRES_PORT=5432
REDIS_URL=redis://localhost:6379
RAILS_ENV=production
FRONTEND_URL=https://your-domain.com
SECRET_KEY_BASE=WILL_BE_GENERATED
RAILS_LOG_TO_STDOUT=true
RAILS_MAX_THREADS=5
ENVFILE

# SECRET_KEY_BASE oluşturma
echo "🔑 SECRET_KEY_BASE oluşturuluyor..."
SECRET_KEY=$(bundle exec rake secret)
sed -i "s|SECRET_KEY_BASE=WILL_BE_GENERATED|SECRET_KEY_BASE=$SECRET_KEY|" .env.production

# Database setup
echo "🗄️  Database migrate ediliyor..."
RAILS_ENV=production bundle exec rails db:create db:migrate

# Assets precompile
echo "🎨 Assets compile ediliyor..."
RAILS_ENV=production bundle exec rails assets:precompile

# Systemd service dosyaları oluşturma
echo "⚙️  Systemd service'leri oluşturuluyor..."

# Web service
sudo tee /etc/systemd/system/chatwoot-web.service > /dev/null << 'WEBSERVICE'
[Unit]
Description=Chatwoot Web Server
After=network.target postgresql.service redis-server.service

[Service]
Type=simple
User=YOUR_USERNAME
WorkingDirectory=/var/www/chatwoot
EnvironmentFile=/var/www/chatwoot/.env.production
ExecStart=/home/YOUR_USERNAME/.rbenv/shims/bundle exec puma -C config/puma.rb
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
WEBSERVICE

# Worker service (Sidekiq)
sudo tee /etc/systemd/system/chatwoot-worker.service > /dev/null << 'WORKERSERVICE'
[Unit]
Description=Chatwoot Sidekiq Worker
After=network.target postgresql.service redis-server.service

[Service]
Type=simple
User=YOUR_USERNAME
WorkingDirectory=/var/www/chatwoot
EnvironmentFile=/var/www/chatwoot/.env.production
ExecStart=/home/YOUR_USERNAME/.rbenv/shims/bundle exec sidekiq -C config/sidekiq.yml
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
WORKERSERVICE

# Nginx yapılandırması
echo "🌐 Nginx yapılandırılıyor..."
sudo tee /etc/nginx/sites-available/chatwoot > /dev/null << 'NGINXCONF'
upstream chatwoot {
    server 127.0.0.1:3000;
}

server {
    listen 80;
    server_name your-domain.com;
    
    client_max_body_size 50M;
    
    location / {
        proxy_pass http://chatwoot;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
NGINXCONF

sudo ln -s /etc/nginx/sites-available/chatwoot /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# Service'leri başlatma
echo "🚀 Service'ler başlatılıyor..."
sudo systemctl daemon-reload
sudo systemctl enable chatwoot-web chatwoot-worker
sudo systemctl start chatwoot-web chatwoot-worker

echo ""
echo "✅ Kurulum tamamlandı!"
echo ""
echo "📝 Sonraki adımlar:"
echo "1. SSL sertifikası kurun: sudo certbot --nginx -d your-domain.com"
echo "2. Super admin oluşturun: RAILS_ENV=production bundle exec rails runner 'SuperAdmin.create!(email: \"admin@example.com\", password: \"ChangeMe123!\", name: \"Admin\")'"
echo "3. Service durumlarını kontrol edin:"
echo "   sudo systemctl status chatwoot-web"
echo "   sudo systemctl status chatwoot-worker"
echo ""
