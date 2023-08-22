#!/bin/bash

# 启动 Apache
apachectl -D FOREGROUND &

# 设置密码文件权限
chmod 600 /usr/local/smokeping/etc/smokeping_secrets.dist &

# 启动 SmokePing
/usr/local/smokeping/bin/smokeping /usr/local/smokeping/etc/config &

# 设置文件文件夹权限
chown www-data:www-data -R /usr/local/smokeping &

# 启动 tail 命令以实时监视 Apache 日志，并将日志输出到容器日志
tail -f /var/log/apache2/access.log

