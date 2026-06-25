可以，而且对于你的场景：

```text
互联网
   ↓
GitHub Actions
   ↓
Dockerfile
   ↓
下载 Docker 官方 DEB 包及依赖
   ↓
reprepro 生成标准 APT 仓库
   ↓
打包 repo.tar.gz
   ↓
移动硬盘
   ↓
内网 Debian
   ↓
apt install docker-ce
```

这是比单纯 `apt-get --download-only + dpkg -i` 更专业、更接近 CentOS `reposync + createrepo` 的方案。

---

# 最终仓库结构

GitHub Actions 产物：

```text
docker-offline-repo/
├── conf/
│   └── distributions
├── dists/
├── pool/
├── install.sh
└── SHA256SUMS
```

内网解压后：

```bash
apt update
apt install docker-ce
```

即可。

---

# 方案设计

## Dockerfile

建议使用 Debian 13（Trixie）

```dockerfile
FROM debian:13

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        dpkg-dev \
        reprepro && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

CMD ["/bin/bash"]
```

这个镜像只负责构建仓库。

---

# GitHub Actions核心逻辑

## 1 添加 Docker 官方仓库

```bash
install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/debian/gpg \
  -o /etc/apt/keyrings/docker.asc

chmod a+r /etc/apt/keyrings/docker.asc

CODENAME=$(grep VERSION_CODENAME /etc/os-release | cut -d= -f2)
ARCH=$(dpkg --print-architecture)

cat >/etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: ${CODENAME}
Components: stable
Architectures: ${ARCH}
Signed-By: /etc/apt/keyrings/docker.asc
EOF
```

---

## 2 下载 Docker 及全部依赖

```bash
apt-get update

apt-get install \
  --download-only \
  --reinstall \
  --yes \
  docker-ce \
  docker-ce-cli \
  containerd.io \
  docker-buildx-plugin \
  docker-compose-plugin
```

包会出现在：

```text
/var/cache/apt/archives/
```

---

## 3 创建 reprepro 仓库

```bash
mkdir -p repo/conf
```

### conf/distributions

```text
Origin: Company
Label: Docker Offline Repo
Codename: trixie
Architectures: amd64
Components: main
Description: Docker Offline Repository
```

---

## 4 导入所有包

```bash
find /var/cache/apt/archives \
    -name "*.deb" \
    -exec reprepro \
        -b repo \
        includedeb \
        trixie \
        {} \;
```

生成：

```text
repo/
├── dists/
└── pool/
```

APT 可直接识别。

---

# install.sh

建议自动生成：

```bash
#!/bin/bash

set -e

REPO_DIR=$(cd "$(dirname "$0")" && pwd)

cat >/etc/apt/sources.list.d/docker-offline.list <<EOF
deb [trusted=yes] file:${REPO_DIR} trixie main
EOF

apt update

apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin

systemctl enable docker
systemctl start docker

docker --version
```

---

# GitHub Actions

```yaml
name: Build Docker Offline Repo

on:
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest

    steps:

      - uses: actions/checkout@v4

      - name: Build image
        run: docker build -t docker-repo-builder .

      - name: Generate Repo
        run: |
          mkdir output

          docker run --rm \
            -v $PWD/output:/output \
            docker-repo-builder \
            bash /workspace/build.sh

      - name: Package
        run: |
          cd output
          tar czf docker-offline-repo.tar.gz repo

      - name: Upload Artifact
        uses: actions/upload-artifact@v4
        with:
          name: docker-offline-repo
          path: output/docker-offline-repo.tar.gz
```

---

# 内网安装

解压：

```bash
tar xf docker-offline-repo.tar.gz
```

执行：

```bash
cd repo

chmod +x install.sh

./install.sh
```

APT 会自动：

```text
containerd.io
↓
docker-ce-cli
↓
docker-ce
↓
buildx
↓
compose
```

排序安装。

---

# 指定 Docker 版本（推荐）

不要直接下载最新版本。

先查看可用版本：

```bash
apt-cache madison docker-ce
```

例如：

```text
5:28.3.3-1~debian.13~trixie
5:28.3.2-1~debian.13~trixie
```

下载指定版本：

```bash
apt-get install \
  --download-only \
  docker-ce=5:28.3.3-1~debian.13~trixie \
  docker-ce-cli=5:28.3.3-1~debian.13~trixie \
  containerd.io
```

这样每次 GitHub Actions 构建结果可复现。

---

# 企业级增强版（推荐）

如果未来不仅同步 Docker，而是：

```text
Docker
Kubernetes
Helm
Harbor
Kafka
Flink
PostgreSQL
MySQL
```

建议升级为：

```text
GitHub Actions
    ↓
Aptly Mirror
    ↓
Snapshot
    ↓
Publish
    ↓
tar.gz
    ↓
内网 nginx
```

因为 `reprepro` 更适合“导入已有包生成仓库”，而 **Aptly** 更适合长期维护完整离线镜像仓库、版本冻结和回滚。

对于单独制作 Docker 离线安装仓库，`apt-get --download-only + reprepro` 已经是一个非常成熟且简单的生产方案。
