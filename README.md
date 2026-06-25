# 使用
```bash

git add .
git commit -m "同步参数yum reposync 方式" 
git -c http.proxy=http://127.0.0.1:7897 -c https.proxy=http://127.0.0.1:7897 push origin main

4. 压缩优化（减少 GitHub artifact）： tar -I 'zstd -19' -cf repo.tar.zst output

# docker 运行多行命令
          docker run --rm \
            -v $PWD/output:/output \
            repo-builder bash -c "

              dnf config-manager \
                --add-repo \
                https://download.docker.com/linux/centos/docker-ce.repo

              dnf reposync \
                --repo=docker-ce-stable \
                --download-metadata \
                --download-path=/output
            "

yum系

验证依赖是否完整
rpm -qpR docker-ce*.rpm

极简方案（直接RPM安装）：
# 直接 rpm 安装（简单但不推荐）
rpm -ivh xxx.rpm 或者 rpm -Uvh --force --nodeps *.rpm
推荐
cd /opt/docker-rpms 然后 yum localinstall -y *.rpm

创建本地仓库
RUN createrepo /offline && ls -lah /offline
拷贝到移动硬盘
offline/
├── *.rpm
└── repodata/

内网机器安装
创建repo文件
cat >/etc/yum.repos.d/docker-local.repo <<EOF
[docker-local]
name=Docker Local Repo
baseurl=file:///opt/docker-rpms
enabled=1
gpgcheck=0
EOF
清理缓存
yum clean all
yum makecache
安装
yum install -y \
docker-ce \
docker-ce-cli \
containerd.io

同步整个 Docker 仓库。
reposync \
-r docker-ce-stable \
-p repo
然后：
createrepo repo/docker-ce-stable
最终得到：
offline-repo/
└── docker-ce-stable
    ├── *.rpm
    └── repodata
内网机器可以直接配置：
baseurl=file:///mnt/repo/docker-ce-stable

# dnf系列
普通安装
dnf install ./pkgs/*.rpm
dnf install -y /offline/docker/*.rpm

# dnf reposync

# 默认dnf reposync是同步全部版本，量很大，可以使用下面方法指定版本，或者添加 --newest-only 只同步最新的
只替换 baseurl 行（企业标准）
sed -i \
's|^baseurl=.*|baseurl=https://download.docker.com/linux/centos/9/x86_64/stable-24/|g' \
/etc/yum.repos.d/docker-ce.repo

# 生成 repo 文件
VERSION=stable-24

cat > docker.repo <<EOF
[docker-ce-stable]
baseurl=https://download.docker.com/linux/centos/9/x86_64/${VERSION}/
enabled=1
gpgcheck=0
EOF

dnf reposync --repo=docker-ce-stable --download-metadata

输出结果结构
生成：docker-offline-repo.tar.gz
解压后：
output/
└── docker-ce-stable/
    ├── Packages/
    │   ├── docker-ce-24.x.rpm
    │   ├── containerd.io.rpm
    │   └── ...
    └── repodata/
        ├── primary.xml
        ├── filelists.xml
        └── repomd.xml
内网使用方式
tar -xzf docker-offline-repo.tar.gz
2️⃣ 创建 repo
cat > /etc/yum.repos.d/docker-local.repo <<EOF
[docker-local]
name=Docker Offline Repo
baseurl=file:///opt/docker-ce-stable
enabled=1
gpgcheck=0
EOF
安装 Docker
dnf install docker-ce docker-ce-cli containerd.io



apt-get

在线机执行：确认依赖是否下载完整？
apt-cache depends docker-ce

方法一：dpkg（不推荐）
apt install -y ./*.deb

dpkg -i *.deb
可能报：dependency problems prevent configuration 因为 dpkg 不会自动解决安装顺序。
dpkg -i \
    ./containerd.io*.deb \
    ./docker-ce-cli*.deb \
    ./docker-ce*.deb \
    ./docker-buildx-plugin*.deb \
    ./docker-compose-plugin*.deb
dpkg -i *.deb 出现：dependency problems  然后执行：apt --fix-broken install

方法二：APT 本地仓库（推荐）
生成索引：
cd /opt/docker-offline/debs
dpkg-scanpackages . /dev/null | gzip -9c > Packages.gz
目录结构：
docker-offline/
 ├── debs/
 │    ├── xxx.deb
 │    ├── xxx.deb
 │    └── Packages.gz
内网机器：配置本地源
假设挂载到：/mnt/usb/docker-offline
添加源：
echo "deb [trusted=yes] file:/mnt/usb/docker-offline/debs ./" \
| sudo tee /etc/apt/sources.list.d/docker-local.list
更新：
sudo apt-get update
安装：
sudo apt-get install -y docker-ce docker-ce-cli containerd.io


# pacman 系列
方案一：直接复制 pacman 缓存
外网机器：pacman -Sw docker
缓存目录：/var/cache/pacman/pkg
复制：
docker*.pkg.tar.zst
containerd*.pkg.tar.zst
runc*.pkg.tar.zst
...
到内网机器：
pacman -U *.pkg.tar.zst
例如：
pacman -U \
containerd.pkg.tar.zst \
runc.pkg.tar.zst \
docker.pkg.tar.zst

方案二：创建离线仓库
Arch 官方提供：repo-add
生成仓库索引：repo-add docker-local.db.tar.gz *.pkg.tar.zst
生成：
docker-local.db.tar.gz
docker-local.files.tar.gz
目录结构：
docker-repo/
├── docker-28.x.pkg.tar.zst
├── containerd.pkg.tar.zst
├── runc.pkg.tar.zst
├── ...
├── docker-local.db.tar.gz
└── docker-local.files.tar.gz
复制到移动硬盘
rsync -av docker-repo /mnt/usb/
内网 Arch Linux 配置本地仓库
mkdir -p /opt/localrepo

cp -r /mnt/usb/docker-repo/* \
      /opt/localrepo/
修改：vim /etc/pacman.conf
添加：
[docker-local]
SigLevel = Optional TrustAll
Server = file:///opt/localrepo
刷新仓库：
pacman -Sy
查看：pacman -Sl docker-local
安装 Docker： pacman -S docker

方案三：建立企业级 Arch 镜像仓库（推荐大规模集群）
如果内网有几十台以上机器，建议搭建：
Nginx
 + Arch Repo
 + Docker Repo
 + 自研软件 Repo
目录：
/repo
 ├── core
 ├── extra
 ├── community
 └── docker-local
同步官方仓库：
rsync \
rsync://mirrors.kernel.org/archlinux \
/repo/archlinux

然后：
server {
    listen 80;

    location /archlinux {
        root /repo;
        autoindex on;
    }
}
客户端：
[core]
Server = http://repo-server/archlinux/core/os/x86_64

[extra]
Server = http://repo-server/archlinux/extra/os/x86_64

[docker-local]
Server = http://repo-server/docker-local



Alpine Linux apk
方案一：直接下载 Docker 全家桶（快速方案）
外网：
mkdir docker-offline

apk fetch --recursive \
    --output docker-offline \
    docker
拷贝：docker-offline/ 到内网。
安装：
apk add --allow-untrusted ./*.apk

方案二：构建完整离线 APK 仓库（生产推荐）
1. 查看目标 Alpine 版本和CPU
cat /etc/alpine-release和uname -m
2. 外网机器准备离线仓库目录
mkdir -p /data/alpine-repo
cd /data/alpine-repo
配置与目标机器一致的仓库：
cat > /etc/apk/repositories <<EOF
https://dl-cdn.alpinelinux.org/alpine/v3.20/main
https://dl-cdn.alpinelinux.org/alpine/v3.20/community
EOF
下载 Docker 及全部依赖
apk fetch --recursive \
    --output /data/alpine-repo \
    docker
查看下载结果：ls /data/alpine-repo
4. 生成仓库索引
apk add alpine-sdk
生成索引：
apk index \
    -o APKINDEX.tar.gz \
    *.apk
目录变成：
/data/alpine-repo

APKINDEX.tar.gz
docker-xxx.apk
containerd-xxx.apk
runc-xxx.apk
...
这已经是一个完整 APK 仓库。
5. 拷贝到移动硬盘
tar czf alpine-docker-repo.tar.gz /data/alpine-repo
6. 内网机器部署
mkdir -p /opt/alpine-repo

tar xf alpine-docker-repo.tar.gz -C /opt
目录：/opt/alpine-repo
7. 配置本地仓库
vi /etc/apk/repositories
内容：
/opt/alpine-repo或者：file:///opt/alpine-repo
8. 更新索引
apk update 应该显示：fetch /opt/alpine-repo/APKINDEX.tar.gz
9. 安装 Docker：apk add docker
10. 启动 Docker：Alpine 默认 OpenRC：
rc-update add docker default
service docker start
查看：
docker version
docker info
方案三：镜像整个 Alpine 仓库（企业级推荐）
使用 rsync
rsync -avz \
 rsync://rsync.alpinelinux.org/alpine/v3.20 \
 /data/alpine-mirror
或者：
wget --mirror \
 --no-parent \
 https://dl-cdn.alpinelinux.org/alpine/v3.20/
目录：
v3.20/
├── main
├── community
内网直接挂载：
http://repo.local/alpine/v3.20
配置：
http://repo.local/alpine/v3.20/main
http://repo.local/alpine/v3.20/community


openSUSE zypper
直接 rpm 安装： rpm -ivh *.rpm (❌ 不会自动处理依赖;❌ 容易缺包;❌ 顺序错就失败)

✔ 外网：
zypper install --download-only docker containerd
cp -ar /var/cache/zypp/packages/* rpms/
生成 repo 元数据
createrepo_c rpms
生成结构：
repodata/
*.rpm
打包移动硬盘
tar -czf docker-offline-repo.tar.gz /data/docker-offline-rpms

✔ 内网：
挂载移动硬盘
mount /dev/sdb1 /mnt
cd /mnt/docker-offline-rpms
添加本地仓库
zypper ar "file:///mnt/docker-offline-rpms" local-docker
zypper refresh
安装 Docker
zypper install docker

搭建内网 HTTP 仓库（推荐）
dnf install nginx: http://repo.local/docker/
离线机器配置：
zypper ar http://repo.local/docker local-docker

```
