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
# RUN pacman -Q docker

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
    pactree -s -u ${pkg} | sort -u >> all_packages.txt; \
done; \
\
cat all_packages.txt | grep -v "\.so=" | sed "s/[><=].*$//" | sort -u > final_packages.txt; \
\
echo "===== all_packages PACKAGE LIST ====="; \
cat all_packages.txt; \
echo "===== final_packages PACKAGE LIST ====="; \
cat final_packages.txt; \

'

RUN ls -lah /offline