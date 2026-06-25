FROM opensuse/leap:15.6

RUN zypper mr -da
RUN zypper ar -p 98 -cfg 'https://mirrors.tuna.tsinghua.edu.cn/opensuse/distribution/leap/$releasever/repo/oss/' mirror-oss
RUN zypper ar -p 98 -cfg 'https://mirrors.tuna.tsinghua.edu.cn/opensuse/distribution/leap/$releasever/repo/non-oss/' mirror-non-oss
RUN zypper ar -p 98 -cfg 'https://mirrors.tuna.tsinghua.edu.cn/opensuse/update/leap/$releasever/oss/' mirror-update
RUN zypper ar -p 98 -cfg 'https://mirrors.tuna.tsinghua.edu.cn/opensuse/update/leap/$releasever/non-oss/' mirror-update-non-oss
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