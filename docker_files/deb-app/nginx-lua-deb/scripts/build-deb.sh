#!/bin/bash
set -e

NGINX_VERSION=1.24.0
# 和 docker_files/deb-app/nginx-lua-deb/debian/control  的Package 相同
PKG=nginx-lua

mkdir -p /build/src
cd /build/src

echo "Downloading nginx..."
wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
tar -xzf nginx-${NGINX_VERSION}.tar.gz

echo "Cloning lua module..."
git clone https://github.com/openresty/lua-nginx-module.git

cd nginx-${NGINX_VERSION}

mkdir -p orig/${PKG}-${VERSION}
mv nginx-${VERSION} orig/${PKG}-${VERSION}/nginx
mv lua-nginx-module orig/${PKG}-${VERSION}/lua-nginx-module
# 打包 orig
cd orig/
tar -czf ${PKG}_${VERSION}.orig.tar.gz ${PKG}-${VERSION}
cp ${PKG}_${VERSION}.orig.tar.gz /build/src/nginx-1.24.0/