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