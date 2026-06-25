FROM archlinux:latest

ENV REPO_DIR=/offline

#RUN echo 'Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch' \
#      > /etc/pacman.d/mirrorlist
#RUN echo 'Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch' \
#      > /etc/pacman.d/mirrorlist
RUN echo 'Server = https://mirrors.ustc.edu.cn/archlinux/$repo/os/$arch' \
        > /etc/pacman.d/mirrorlist

RUN pacman -Sy --noconfirm \
        pacman-contrib \
        base-devel \
        rsync \
        git \
        curl \
        wget \
        aria2

RUN mkdir -p ${REPO_DIR}

RUN pacman -Ss docker

# docker-buildx \ 新版本才有 【docker-compose \ 不存在】
RUN bash -c '\
set -eux; \
\
PACKAGES="\
docker \
"; \
\
cd ${REPO_DIR}; \
\
touch all_packages.txt; \
\
for pkg in ${PACKAGES}; do \
    echo "Resolving dependencies for ${pkg}"; \
    pactree -u ${pkg} | sort -u >> all_packages.txt; \
done; \
\
sort -u all_packages.txt > final_packages.txt; \
\
echo "===== PACKAGE LIST ====="; \
cat final_packages.txt; \

'

RUN ls -lah /offline