FROM debian:12

# 参考： https://yeasy.gitbook.io/docker_practice/di-er-bu-fen-jin-jie-pian/07_dockerfile/7.3_add
# ARG指令在构建镜像时设置环境变量，而ENV指令在运行容器时设置环境变量。
# ARG指令是在构建过程中使用的，而ENV指令是在容器运行时使用的。
# ARG指令可以通过–build-arg参数传递值，而ENV指令不能。
# ARG指令可以将环境变量传递给后续的指令，而ENV指令只能在当前指令中使用。
# 1. 定义 ARG 默认值 (如果构建时不传参，使用默认的 v1.0): docker build --build-arg APP_VERSION=v2.0
ARG HOST_WORK_DIR='.'

# 2. 将 ARG 赋值给 ENV，使参数能在容器运行时生效
ENV HOST_WORKDIR=$HOST_WORK_DIR

# 验证
RUN echo "Github Actions 宿主机工作目录 : $HOST_WORKDIR"

ENV DEBIAN_FRONTEND=noninteractive


WORKDIR /build

COPY docker_files/deb-app/nginx-lua-deb/ /build/

RUN chmod +x debian/rules

RUN apt-get update && apt-get install -y \
    build-essential \
    dpkg-dev \
    devscripts \
    fakeroot \
    debhelper \
    git \
    wget \
    curl \
    libpcre3-dev \
    zlib1g-dev \
    libssl-dev \
    libluajit-5.1-dev \
    dos2unix \
    ca-certificates

RUN ls -alh /build/

RUN bash /build/scripts/build-deb.sh
RUN ls -alh /build/src

RUN bash /build/scripts/build.sh

