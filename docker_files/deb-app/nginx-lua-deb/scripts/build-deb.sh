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

mkdir -p orig/${PKG}-${NGINX_VERSION}
mv nginx-${NGINX_VERSION} orig/${PKG}-${NGINX_VERSION}/nginx
mv lua-nginx-module orig/${PKG}-${NGINX_VERSION}/lua-nginx-module
# 打包 orig
cd orig/
tar -czf ${PKG}_${NGINX_VERSION}.orig.tar.gz ${PKG}-${NGINX_VERSION}
ls -alh
cp ${PKG}_${NGINX_VERSION}.orig.tar.gz /build/src/nginx-${NGINX_VERSION}/
cd ..

cd nginx-${NGINX_VERSION}