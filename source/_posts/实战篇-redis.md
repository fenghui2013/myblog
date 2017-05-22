---
title: 实战篇-redis
date: 2017-05-21 13:44:46
tags:
    - redis
---

#### 安装

[官方传送门](https://redis.io/download)

```
wget http://download.redis.io/releases/redis-3.2.9.tar.gz
tar xzf redis-3.2.9.tar.gz
cd redis-3.2.9
make
make install
```

```
redis-server            # 服务启动程序
redis-cli               # 客户端程序
redis-benchmark         # 性能测试工具
```

redis.conf

```
bind 127.0.0.1               # 监听某些接口
protected-mode yes           # 如果想让其他主机访问，则设为no
port 6379                    # 监听端口
tcp-backlog 511              # 

```