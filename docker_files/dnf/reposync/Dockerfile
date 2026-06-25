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

# -n 只下载最新版本 全称 --newest-only
# -l 跟随依赖
RUN dnf reposync \
    --repo=docker-ce-stable \
    --download-metadata \
    -n \
    -l \
    -p /offline

RUN ls -lah /offline
