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

# 更换软件包源为中国科技大学（USTC）的镜像源
# 国外服务器请注释掉
RUN sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list && \
    sed -i 's/security.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list && \
    apt-get update

# 更新软件包源并安装必要的依赖
RUN apt-get update && \
    apt-get install -y apache2 libapache2-mod-fcgid fping fonts-wqy-zenhei librrds-perl && \
    rm -rf /var/lib/apt/lists/*

# 从编译阶段复制smokeping可执行文件到运行时阶段
COPY --from=build /usr/local/smokeping /usr/local/smokeping

# 创建用于缓存的目录
RUN mkdir -p /usr/local/smokeping/cache && \
    mkdir -p /usr/local/smokeping/data && \
    mkdir -p /usr/local/smokeping/var \
    mkdir -p /usr/local/smokeping/etc

# 设置权限
# RUN chown www-data:www-data -R /usr/local/smokeping

# 暴露SmokePing的Web界面端口
EXPOSE 80

# 添加 SmokePing 的 Apache 配置文件
COPY apache2_config /etc/apache2/conf-available/

# 启用 SmokePing 的 Apache 配置文件并启用所需的模块
RUN ln -s /etc/apache2/conf-available/smokeping.conf /etc/apache2/conf-enabled/ && \
    a2enconf smokeping && \
    a2enmod cgid

# 解决apache2爆数组问题
RUN sed -i 's/FcgidConnectTimeout 20/FcgidConnectTimeout 20\n   MaxRequestLen 157286400000/g' /etc/apache2/mods-available/fcgid.conf

# 将启动命令放入一个脚本
COPY start.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start.sh

# 启动容器时执行脚本
CMD ["/usr/local/bin/start.sh"]
