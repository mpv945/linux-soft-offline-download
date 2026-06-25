如果你的目标是：

```text
外网 GitHub Actions
        ↓
同步 Docker 官方 Debian 仓库
        ↓
生成标准 APT 离线仓库
        ↓
导出 tar.gz
        ↓
移动硬盘
        ↓
内网 Debian 12/13
        ↓
apt install docker-ce
```

那么 **Aptly 比 reprepro 更适合**。

原因：

| 功能         | reprepro | Aptly |
| ---------- | -------- | ----- |
| 导入指定deb    | √        | √     |
| 镜像官方仓库     | ×        | √     |
| Snapshot快照 | ×        | √     |
| 版本冻结       | ×        | √     |
| 增量同步       | ×        | √     |
| 仓库签名       | √        | √     |
| 企业级长期维护    | ⭐⭐⭐      | ⭐⭐⭐⭐⭐ |

对于 Docker 官方仓库：

```text
https://download.docker.com/linux/debian
```

最好的方式是：

```text
Aptly Mirror
↓
Snapshot
↓
Publish
↓
Offline Repo
```

类似 Rocky Linux：

```text
reposync
↓
createrepo
```

---

# 一、最终目录结构

GitHub Actions 输出：

```text
docker-offline-repo/
├── public/
│   ├── dists/
│   ├── pool/
│   └── ...
├── install.sh
└── SHA256SUMS
```

内网：

```bash
./install.sh
```

即可：

```bash
apt install docker-ce
```

---

# 二、Dockerfile

建议使用 Debian 13。

```dockerfile
FROM debian:13

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
        curl \
        ca-certificates \
        gnupg \
        aptly && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

COPY build-repo.sh /workspace/

RUN chmod +x /workspace/build-repo.sh

CMD ["/workspace/build-repo.sh"]
```

---

# 三、build-repo.sh

这是核心脚本。

```bash
#!/bin/bash

set -euo pipefail

REPO_DIR=/output

mkdir -p "${REPO_DIR}"

#
# Docker GPG
#
mkdir -p /etc/apt/keyrings

curl -fsSL \
  https://download.docker.com/linux/debian/gpg \
  -o /etc/apt/keyrings/docker.asc

#
# Docker Mirror
#
aptly mirror create \
  -architectures=amd64 \
  docker-trixie \
  https://download.docker.com/linux/debian \
  trixie \
  stable

#
# Download
#
aptly mirror update docker-trixie

#
# Snapshot
#
SNAPSHOT=docker-$(date +%Y%m%d)

aptly snapshot create \
  ${SNAPSHOT} \
  from mirror docker-trixie

#
# Publish
#
aptly publish snapshot \
  -distribution=trixie \
  ${SNAPSHOT}

#
# Export
#
cp -a ~/.aptly/public \
      "${REPO_DIR}/"

sha256sum \
    $(find "${REPO_DIR}" -type f) \
    > "${REPO_DIR}/SHA256SUMS"
```

---

# 四、限制只同步 Docker 相关包（推荐）

直接 Mirror 整个 Docker 仓库会下载很多历史版本。

可以加 Filter。

先查询 Docker 包：

```bash
aptly mirror search docker-trixie docker-ce
```

然后：

```bash
aptly mirror create \
    -architectures=amd64 \
    -filter='docker-ce|docker-ce-cli|containerd.io|docker-buildx-plugin|docker-compose-plugin' \
    -filter-with-deps \
    docker-trixie \
    https://download.docker.com/linux/debian \
    trixie \
    stable
```

这里：

```text
-filter-with-deps
```

非常关键。

会自动拉取：

```text
docker-ce
docker-ce-cli
containerd.io
docker-buildx-plugin
docker-compose-plugin

以及全部依赖
```

这样仓库大小会从几GB降到几百MB。

---

# 五、GitHub Actions

```yaml
name: Build Docker Offline Repo

on:
  workflow_dispatch:

jobs:

  build:

    runs-on: ubuntu-latest

    steps:

      - uses: actions/checkout@v4

      - name: Build Builder Image
        run: |
          docker build \
            -t aptly-builder \
            .

      - name: Generate Repo
        run: |
          mkdir output

          docker run --rm \
            -v $PWD/output:/output \
            aptly-builder

      - name: Package
        run: |
          cd output

          tar czf \
            docker-offline-repo.tar.gz \
            public \
            SHA256SUMS

      - name: Upload
        uses: actions/upload-artifact@v4
        with:
          name: docker-offline-repo
          path: output/docker-offline-repo.tar.gz
```

---

# 六、生成 install.sh

放到 output 目录：

```bash
#!/bin/bash

set -e

REPO_DIR=$(cd "$(dirname "$0")" && pwd)

cat >/etc/apt/sources.list.d/docker-offline.sources <<EOF
Types: deb
URIs: file:${REPO_DIR}/public
Suites: trixie
Components: main
Trusted: yes
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
```

---

# 七、内网安装

解压：

```bash
tar xf docker-offline-repo.tar.gz
```

目录：

```text
public/
install.sh
SHA256SUMS
```

验证：

```bash
sha256sum -c SHA256SUMS
```

安装：

```bash
chmod +x install.sh

./install.sh
```

APT 会自动处理：

```text
依赖解析
安装顺序
版本校验
```

---

# 八、指定 Docker 版本（企业推荐）

先查看 Docker 仓库中的版本：

```bash
aptly mirror update docker-trixie
aptly mirror search docker-trixie docker-ce
```

然后使用更精确的过滤器：

```bash
aptly mirror create \
  -architectures=amd64 \
  -filter='docker-ce (= 5:28.5.1-1~debian.13~trixie)|docker-ce-cli (= 5:28.5.1-1~debian.13~trixie)|containerd.io' \
  -filter-with-deps \
  docker-trixie \
  https://download.docker.com/linux/debian \
  trixie \
  stable
```

这样生成的离线仓库完全可复现。

---

## 我对企业环境的建议

如果后续你不仅同步 Docker，还要同步：

* Kubernetes（kubeadm、kubelet、kubectl）
* Helm
* Harbor
* PostgreSQL
* MySQL
* Kafka
* Flink

建议建立一个统一的：

```text
Aptly Mirror
    ↓
Snapshot
    ↓
Publish
    ↓
Offline Repository Bundle
```

体系。

它在 Debian 世界中的定位，就是 Rocky/CentOS 里的：

```text
reposync
    ↓
createrepo
    ↓
本地YUM仓库
```

而且具备版本冻结和回滚能力，更适合长期维护内网集群。