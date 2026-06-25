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

RUN mkdir -p /offline && yum list docker-ce --showduplicates

RUN repotrack \
      -p /offline \
      docker-ce \
      docker-ce-cli \
      containerd.io

RUN createrepo /offline

FROM scratch

COPY --from=builder /offline /