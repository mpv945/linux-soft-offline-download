FROM opensuse/leap:15.6

RUN set -eux; \
    zypper --non-interactive refresh || true; \
    zypper --non-interactive install -y createrepo_c curl tar gzip

WORKDIR /offline

# RUN zypper install --download-only --download-dir /offline docker containerd

# --download-dir 不设置时的默认目录 /var/cache/zypp/packages/
RUN zypper install --download-only --download-dir ./ -y docker containerd

# createrepo_c /data/docker-offline-rpms
# 如果你后面追加 rpm，不要重建，用： createrepo_c --update .
RUN createrepo_c .

RUN ls -lah .