FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    ca-certificates curl gnupg dpkg-dev \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

RUN mkdir -p /offline && \
    set -eux; \
    \
    # 1. 添加 Docker GPG
    install -m 0755 -d /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg \
      | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    \
    # 2. 添加 Docker 源
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
    https://download.docker.com/linux/debian $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
    > /etc/apt/sources.list.d/docker.list && \
    \
    # 3. 更新索引
    apt-get update && \
    \
    # 4. 下载 docker 相关包（不安装）
    apt-get install --download-only -y \
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
    ls -lah /offline && cat /etc/apt/sources.list.d/docker.list