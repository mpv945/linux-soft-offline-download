FROM centos:7 AS builder

RUN sed -i \
    's/mirror.centos.org/vault.centos.org/g' \
    /etc/yum.repos.d/CentOS-Base.repo && \
    sed -i \
    's/^#baseurl/baseurl/g' \
    /etc/yum.repos.d/CentOS-Base.repo && \
    sed -i \
    's/^mirrorlist/#mirrorlist/g' \
    /etc/yum.repos.d/CentOS-Base.repo

RUN yum install -y \
    yum-utils \
    createrepo \
    curl

RUN yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

RUN yum repolist && mkdir -p /offline && yum list docker-ce --showduplicates

# -n 只下载最新版本
# -l 跟随依赖
RUN reposync \
    -r docker-ce-stable \
    --download-metadata \
    -n \
    -l \
    -p /offline

RUN ls -lah /offline
