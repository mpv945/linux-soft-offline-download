# 使用
```bash

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
rpm -ivh xxx.rpm 或者 rpm -Uvh --force --nodeps *.rpm
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


```
