#!/bin/bash

set -euo pipefail

apt update && apt upgrade -y

apt install -y \
    npm \
    git \
    nginx

git clone https://github.com/ansi-semifir/ReactMeteo.git

pushd ReactMeteo

npm install

npm run build

sed -i 's/background-color:#2a5f7e/background-color:#'$(openssl rand -hex 3)'/' build/static/css/*
sed -i 's/background-color: #2a5f7e/background-color:#'$(openssl rand -hex 3)'/' build/static/css/*

cp -r ./build /var/www/reactmeteo

popd

cat <<'EOF' | sudo tee /etc/nginx/sites-available/reactmeteo
server {
        listen 80;
        listen [::]:80;

        root /var/www/reactmeteo;

        index index.html index.htm index.nginx-debian.html;

        server_name reactmeteo;

        location / {
                try_files $uri $uri/ =404;
        }
}
EOF

unlink /etc/nginx/sites-enabled/default
ln -s /etc/nginx/sites-available/reactmeteo /etc/nginx/sites-enabled/reactmeteo

systemctl restart nginx.service
