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
```
