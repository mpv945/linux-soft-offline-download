FROM archlinux:latest

ENV REPO_DIR=/offline

#RUN echo 'Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch' \
#      > /etc/pacman.d/mirrorlist
#RUN echo 'Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch' \
#      > /etc/pacman.d/mirrorlist
RUN echo 'Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch' \
        > /etc/pacman.d/mirrorlist

RUN pacman -Sy --noconfirm

RUN mkdir -p ${REPO_DIR}
# 能搜索到包，说明包就存在
RUN pacman -Ss docker docker-compose
# RUN pacman -Q docker

# docker-buildx \ 新版本才有 【docker-compose \ 不存在】
RUN pacman -Sw \
    --noconfirm \
    --cachedir ${REPO_DIR} \
    docker docker-compose

RUN cd ${REPO_DIR} && \
    repo-add offline.db.tar.gz *.pkg.tar.zst

RUN ls -lah ${REPO_DIR}