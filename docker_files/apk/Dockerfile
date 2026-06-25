FROM alpine:3.22

ENV REPO_DIR=/offline

RUN apk add --no-cache \
    alpine-sdk \
    apk-tools \
    tar

#WORKDIR ${REPO_DIR}

RUN mkdir -p ${REPO_DIR}

#
# 下载 Docker 及所有依赖
#
#RUN apk fetch \
#        --recursive \
#        --output ${REPO_DIR} \
#        docker \
#        docker-cli \
#        containerd \
#        runc \
#        iptables \
#        bash \
#        curl \
#        wget \
#        ca-certificates
# 下载docker核心（有时候可能会少依赖)
RUN apk fetch \
        --recursive \
        --output ${REPO_DIR} \
        docker

#
# 生成仓库索引
#
RUN cd ${REPO_DIR} && \
    apk index -o APKINDEX.tar.gz *.apk

#
# 打包离线仓库
#
#RUN cd /offline-repo/output && \
#    tar czf /offline-repo/docker-alpine-offline-repo.tar.gz .

#CMD ["sh","-c","cp /offline-repo/docker-alpine-offline-repo.tar.gz /output/"]

RUN ls -lah ${REPO_DIR}