#!/bin/bash
set -e

cd /build/src/nginx-1.24.0

echo "Creating debian structure..."
cp -r /build/* .
ls -alh .


#cat > ./debian/control <<EOF
#Source: nginx-lua
#Section: web
#Priority: optional
#Maintainer: you <you@example.com>
#
#Build-Depends: debhelper-compat (= 13),
#               libpcre3-dev,
#               zlib1g-dev,
#               libssl-dev,
#               libluajit-5.1-dev
#
#Package: nginx-lua
#Architecture: amd64
#Depends: \${shlibs:Depends}, \${misc:Depends}
#Description: Nginx with Lua support
# Custom nginx build
#EOF

dos2unix debian/control
dos2unix debian/*

echo "checking control file... cat -A 出现 $   ⚠ CRLF"
nl -ba ./debian/control
cat -A debian/control
echo "validating..."

dpkg-source -b . || true

echo "Building deb package..."
dpkg-buildpackage -us -uc -b

mkdir -p /offline && cp nginx-lua_*.deb /offline/

ls -alh /offline/