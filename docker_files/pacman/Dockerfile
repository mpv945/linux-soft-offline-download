FROM archlinux:latest

ENV REPO_DIR=/offline

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
        pacman-contrib \
        base-devel \
        rsync \
        aria2

RUN mkdir -p ${REPO_DIR}

RUN bash -c '\
set -eux; \
\
PACKAGES="\
docker \
docker-compose \
git \
curl \
wget \
vim \
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
\
pacman -Sw \
    --noconfirm \
    --cachedir ${REPO_DIR} \
    $(cat final_packages.txt); \
\
repo-add \
    offline.db.tar.gz \
    *.pkg.tar.zst; \
\
tar czf \
    arch-offline-repo.tar.gz \
    *.pkg.tar.zst \
    offline.db.tar.gz \
    offline.files.tar.gz \
    final_packages.txt; \
\
echo "Repository Build Finished"; \
'

RUN ls -lah /offline