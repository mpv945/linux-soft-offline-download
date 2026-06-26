#!/bin/bash
set -e

cd /build/src/nginx-1.24.0

echo "Creating debian structure..."
cp -r /build/nginx-lua-deb/nginx/debian .

cat > ./debian/control <<EOF
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

echo "Building deb package..."
dpkg-buildpackage -us -uc -b

mkdir -p /offline && cp nginx-lua_*.deb /offline/

ls -alh /offline/