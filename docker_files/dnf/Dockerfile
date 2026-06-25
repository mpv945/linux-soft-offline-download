# FROM rockylinux:9-minimal AS builder
FROM rockylinux:9 AS builder

RUN dnf install -y \
    dnf-plugins-core \
    createrepo_c \
    curl \
    tar \
    gzip \
    && dnf clean all

RUN dnf config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

RUN mkdir -p /offline && dnf list docker-ce --showduplicates

RUN dnf download --resolve --alldeps \
      --destdir=/offline \
      docker-ce \
      docker-ce-cli \
      containerd.io \
      docker-buildx-plugin \
      docker-compose-plugin

RUN createrepo_c /offline && ls -lah /offline
