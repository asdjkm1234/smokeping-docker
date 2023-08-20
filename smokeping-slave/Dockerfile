# 使用官方的Debian 11作为基础镜像
FROM debian:11 AS build

# 更换软件包源为中国科技大学（USTC）的镜像源
# 国外服务器请注释掉
RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list && \
    sed -i 's/security.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list && \
    apt-get update

# 更新软件包源并安装必要的依赖
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        gcc make libwww-perl libcgi-fast-perl libtext-soundex-perl \
        libio-pty-perl libcrypt-ssleay-perl rrdtool librrds-perl \
        libssl-dev libc6-dev wget autoconf fping acl curl apache2 \
        git graphviz imagemagick libapache2-mod-fcgid mtr-tiny nmap fonts-wqy-zenhei; \
    rm -rf /var/lib/apt/lists/*; \
    apt-get clean; \
    rm -rf /tmp/*


# 下载并提取SmokePing源码包
WORKDIR /usr/local/src
RUN wget https://oss.oetiker.ch/smokeping/pub/smokeping-2.8.2.tar.gz && \
    tar zxf smokeping-2.8.2.tar.gz

# 编译并安装SmokePing
WORKDIR /usr/local/src/smokeping-2.8.2
RUN LC_ALL=C ./configure --prefix=/usr/local/smokeping && \
    make install

# 开始运行时阶段
FROM debian:11 as runtime

# 从编译阶段复制smokeping可执行文件到运行时阶段
COPY --from=build /usr/local/smokeping /usr/local/smokeping

# 更换软件包源为中国科技大学（USTC）的镜像源
# 国外服务器请注释掉
RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list && \
    sed -i 's/security.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list && \
    apt-get update

# 更新软件包源并安装必要的依赖
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        libfindbin-libs-perl librrds-perl fping; \
    rm -rf /var/lib/apt/lists/*; \
    apt-get clean; \
    rm -rf /tmp/*

# 创建cache文件夹
RUN mkdir -p /usr/local/smokeping/cache/

# 接收环境变量
ENV SMOKEPING_MASTER_URL=""
ENV SMOKEPING_SHARED_SECRET=""
ENV SMOKEPING_SLAVE_NAME=""

#设置密码文件权限为600
RUN chmod 600 /usr/local/smokeping/etc/smokeping_secrets.dist

CMD echo "${SMOKEPING_SHARED_SECRET}" > /usr/local/smokeping/etc/smokeping_secrets.dist && \
    /usr/local/smokeping/bin/smokeping \
    --master-url="${SMOKEPING_MASTER_URL}" \
    --cache-dir=/usr/local/smokeping/cache/ \
    --shared-secret=/usr/local/smokeping/etc/smokeping_secrets.dist \
    --slave-name="${SMOKEPING_SLAVE_NAME}" \
    --logfile=/var/log/smokeping_slave.log && \
    tail -f /var/log/smokeping_slave.log

