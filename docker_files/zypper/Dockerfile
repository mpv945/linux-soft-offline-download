FROM opensuse/leap:15.6

#RUN zypper ar https://download.opensuse.org/repositories/Virtualization:/containers/openSUSE_Leap_15.6/ containers

RUN set -eux; \
    zypper --non-interactive refresh || true; \
    zypper removerepo containers || true; \
    zypper --non-interactive --gpg-auto-import-keys refresh || true

RUN zypper --non-interactive install -y \
    zypper-download \
    createrepo_c || true

WORKDIR /offline

# RUN zypper install --download-only --download-dir /offline docker containerd

# --download-dir 不设置时的默认目录 /var/cache/zypp/packages/
RUN zypper install docker containerd --download-only --download-dir ./

# createrepo_c /data/docker-offline-rpms
# 如果你后面追加 rpm，不要重建，用： createrepo_c --update .
RUN createrepo_c .

RUN ls -lah .