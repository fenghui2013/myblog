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

# 配置redis可用的最大内存数及对应的内存回收算法
maxmemory                    # 可占用的最大内存
maxmemory-policy             # 内存回收算法 volatile-lru allkeys-lru

# 服务器中数据库的数量
databases = 16

#  K     Keyspace events, published with __keyspace@<db>__ prefix.
#  E     Keyevent events, published with __keyevent@<db>__ prefix.
#  g     Generic commands (non-type specific) like DEL, EXPIRE, RENAME, ...
#  $     String commands
#  l     List commands
#  s     Set commands
#  h     Hash commands
#  z     Sorted set commands
#  x     Expired events (events generated every time a key expires)
#  e     Evicted events (events generated when a key is evicted for maxmemory)
#  A     Alias for g$lshzxe, so that the "AKE" string means all the events.
notify-keyspace-events "K$"   # 发布订阅配置

# 异步RDB持久化配置  格式:save <seconds> <changes>
save 900 1
save 300 10
save 60 10000

# AOF持久化配置
appendonly yes                    # 开启AOF持久化功能
appendfilename "appendonly.aof"   # 持久化文件名
# no: don't fsync, just let the OS flush the data when it wants. Faster.
# always: fsync after every write to the append only log. Slow, Safest.
# everysec: fsync only one time every second. Compromise.
appendfsync always                # 持久化模式

hz 10                             # serverCron函数 每秒执行次数 
```