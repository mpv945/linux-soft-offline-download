FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    ca-certificates curl gnupg dpkg-dev \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

RUN mkdir -p /offline && \
    set -eux; \
    \
    # Docker 官方 keyring
    install -m 0755 -d /etc/apt/keyrings; \
    curl -fsSL https://download.docker.com/linux/debian/gpg \
        -o /etc/apt/keyrings/docker.asc; \
    chmod a+r /etc/apt/keyrings/docker.asc; \
    \
    # 2. 添加 Docker 源
    CODENAME=$(. /etc/os-release && echo "$VERSION_CODENAME") && \
        ARCH=$(dpkg --print-architecture) && \
        printf '%s\n' \
          'Types: deb' \
          'URIs: https://download.docker.com/linux/debian' \
          "Suites: ${CODENAME}" \
          'Components: stable' \
          "Architectures: ${ARCH}" \
          'Signed-By: /etc/apt/keyrings/docker.asc' \
          > /etc/apt/sources.list.d/docker.sources && \
    \
    # 3. 更新索引
    apt update && \
    \
    # 4. 下载 docker 相关包（不安装）
    apt install --download-only -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin && \
    \
    # 5. 拷贝 deb
    cp -a /var/cache/apt/archives/*.deb /offline/ && \
    \
    # 6. 生成本地 repo（类似 createrepo）
    cd /offline && \
    dpkg-scanpackages . /dev/null | gzip -9c > Packages.gz && \
    \
    # 7. 打包，只打包 debs目录：  cp -a /var/cache/apt/archives/*.deb /output/debs/ && \
    #tar -czf /output/docker-offline.tar.gz -C /output debs
    ls -lah /offline && cat /etc/apt/sources.list.d/docker.sources