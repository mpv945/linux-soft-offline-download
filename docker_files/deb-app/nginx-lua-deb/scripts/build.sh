#!/bin/bash
set -e

cd /build/src/nginx-1.24.0

echo "Creating debian structure..."
cp -r /build/debian .
cp -r /build/nginx .
ls -alh .

sed -i -e '$a\' nginx/conf/nginx.conf
sed -i -e '$a\' nginx/lua/hello.lua

# Build-Depends: debhelper-compat (=13), libpcre3-dev, zlib1g-dev, libssl-dev, lua5.3, liblua5.3-dev
# Build-Depends: debhelper-compat (=13), libpcre3-dev, zlib1g-dev, libssl-dev, lua5.1, liblua5.1-0-dev
cat > debian/control <<'EOF'
Source: nginx-lua
Section: web
Priority: optional
Maintainer: Your Name <you@example.com>
Build-Depends: debhelper-compat (=13), libpcre3-dev, zlib1g-dev, libssl-dev, lua5.3, liblua5.3-dev
Standards-Version: 4.6.2

Package: nginx-lua
Architecture: amd64
Depends: ${shlibs:Depends}, ${misc:Depends}
Description: Nginx with Lua module
 Custom nginx build with embedded Lua support
EOF

# debian/source/format = 3.0 (quilt) 必须有“上游源码 tarball”  ✔ native 模式特点：不需要 .orig.tar.*
# echo "3.0 (native)" > debian/source/format

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