#!/bin/bash
set -e

cd /build/src/nginx-1.24.0

echo "Creating debian structure..."
cp -r /build/nginx/debian .

echo "Building deb package..."
dpkg-buildpackage -us -uc -b