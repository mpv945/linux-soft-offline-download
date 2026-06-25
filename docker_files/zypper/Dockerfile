FROM opensuse/leap:15.6

RUN set -eux; \
    zypper --non-interactive refresh || true; \
    zypper --non-interactive install -y createrepo_c curl tar gzip

WORKDIR /offline

# RUN zypper install --download-only --download-dir /offline docker containerd

RUN zypper help install
# --download-dir 不设置时的默认目录 /var/cache/zypp/packages/

# --force-resolution 自动尝试“最激进”的依赖组合;强行找一个“能装成功的解” 👉 强行解决依赖冲突（偏“暴力解”）
# --recommends 👉 安装“推荐依赖包”，不仅仅是必须依赖（required dependencies） 👉 安装“推荐功能包”（更完整但更大）
RUN zypper install --download-only --recommends -y docker containerd
RUN cp -ar /var/cache/zypp/packages/* .

# createrepo_c /data/docker-offline-rpms
# 如果你后面追加 rpm，不要重建，用： createrepo_c --update .
RUN createrepo_c .

RUN ls -lah .