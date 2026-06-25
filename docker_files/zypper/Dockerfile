FROM opensuse/leap:15.6

# 禁用官方软件源
RUN zypper mr -da

RUN zypper ar -p 95 -cfg --refresh 'https://download.opensuse.org/distribution/leap/15.6/repo/oss/' repo1-oss
RUN zypper ar -p 95 -cfg --refresh 'https://download.opensuse.org/update/leap/15.6/backports/' repo1-backports

RUN zypper ar -p 96 -cfg --refresh 'https://download.opensuse.org/repositories/Virtualization:/containers/openSUSE_Leap_15.5/' vm-containers
# 添加镜像源，并启用更高优先级用以覆盖官方镜像（可更改 98 为更小的数字，越小优先级越高）
RUN zypper ar -p 98 -cfg 'https://mirrors.tuna.tsinghua.edu.cn/opensuse/distribution/leap/$releasever/repo/oss/' mirror-oss
RUN zypper ar -p 98 -cfg 'https://mirrors.tuna.tsinghua.edu.cn/opensuse/distribution/leap/$releasever/repo/non-oss/' mirror-non-oss
RUN zypper ar -p 98 -cfg 'https://mirrors.tuna.tsinghua.edu.cn/opensuse/update/leap/$releasever/oss/' mirror-update
RUN zypper ar -p 98 -cfg 'https://mirrors.tuna.tsinghua.edu.cn/opensuse/update/leap/$releasever/non-oss/' mirror-update-non-oss
# Leap 15.3 或更新版本还需添加 sle 和 backports 源
RUN zypper ar -p 98 -cfg 'https://mirrors.tuna.tsinghua.edu.cn/opensuse/update/leap/$releasever/sle/' mirror-sle-update
RUN zypper ar -p 98 -cfg 'https://mirrors.tuna.tsinghua.edu.cn/opensuse/update/leap/$releasever/backports/' mirror-backports-update
# 刷新软件源
RUN zypper ref

RUN zypper install -y \
    zypper-download \
    createrepo_c

WORKDIR /offline

# RUN zypper install --download-only --download-dir /offline docker containerd

# --download-dir 不设置时的默认目录 /var/cache/zypp/packages/
RUN zypper install -y docker containerd --download-only --download-dir ./

# createrepo_c /data/docker-offline-rpms
# 如果你后面追加 rpm，不要重建，用： createrepo_c --update .
RUN createrepo_c .

RUN ls -lah .