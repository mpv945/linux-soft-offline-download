# FROM rockylinux:9-minimal AS builder
FROM rockylinux:9 AS builder

RUN dnf install -y \
    dnf-plugins-core \
    curl \
    tar \
    gzip \
    --allowerasing  \
    && dnf clean all

RUN dnf config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

RUN dnf repolist && mkdir -p /offline && dnf list docker-ce --showduplicates

RUN dnf reposync \
    --repo=docker-ce-stable \
    --download-metadata \
    --newest-only \
    -p /offline

RUN ls -lah /offline
