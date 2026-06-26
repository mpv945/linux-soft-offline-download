#!/bin/bash
set -e

NGINX_VERSION=1.24.0

mkdir -p /build/src
cd /build/src

echo "Downloading nginx..."
wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
tar -xzf nginx-${NGINX_VERSION}.tar.gz

echo "Cloning lua module..."
git clone https://github.com/openresty/lua-nginx-module.git

cd nginx-${NGINX_VERSION}

cat > /build/nginx-lua-deb/nginx/build.sh <<EOF
Source: nginx-lua
Section: web
Priority: optional
Maintainer: you <you@example.com>

Build-Depends: debhelper-compat (= 13),
               libpcre3-dev,
               zlib1g-dev,
               libssl-dev,
               libluajit-5.1-dev

Package: nginx-lua
Architecture: amd64
Depends: \${shlibs:Depends}, \${misc:Depends}
Description: Nginx with Lua support
 Custom nginx build
EOF