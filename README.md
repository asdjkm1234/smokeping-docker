# 使用教程

## 前置环境准备
- docker环境
- x86架构

docker的安装请参考其他教程。这里推荐使用官方脚本
```
curl -sSL https://get.docker.com/ | sh
systemctl enable docker
systemctl start docker
```

## 使用docker compose快速部署主节点面板

1. 克隆本项目
```
git clone https://github.com/asdjkm1234/smokeping-docker.git
```

2. 进入根目录
```
# cd smokeping-docker/
```

3. 编辑smokeping配置文件和探针密码

> PS:配置格式可以参考别的教程
```
vim smokeping_config/config  
vim smokeping_config/smokeping_secrets.dist
```

4. 启动master面板
```
docker compose up -d
docker logs -f smokeping-master
```
5. 访问smokeping探针
   
http://your.server.ip:8080/smokeping/smokeping.fcgi.dist


## 使用docker run快速对接从节点
```
docker run -itd \
--name smokeping-slave \
-e SMOKEPING_MASTER_URL="http://your.server.domain:8080/smokeping/smokeping.fcgi.dist" \
-e SMOKEPING_SHARED_SECRET="123456" \
-e SMOKEPING_SLAVE_NAME="host1" \
asdjkm1234/smokeping-slave:v1
```

## 关闭容器及其他管理指令

- 关闭master面板
```
cd /your/project/path/
docker compose down
```

- 关闭slave探针
```
docker stop smokeping-slave && docker rm smokeping-slave
```

- 查看slave探针日志
```
docker logs -f smokeping-slave
```
