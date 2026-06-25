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



```
