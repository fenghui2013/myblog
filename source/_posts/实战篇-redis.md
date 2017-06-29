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
redis-server path/to/redis.conf              # 服务启动程序
redis-sentinel path/to/sentinel.conf         # 启动一个哨兵节点
redis-cli                                    # 客户端程序
redis-benchmark                              # 性能测试工具
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

notify-keyspace-events "K$"   # 发布订阅配置

######## SNAPSHOTTING ########
# 异步RDB持久化配置  格式:save <seconds> <changes>
save 900 1
save 300 10
save 60 10000

stop-writes-on-bgsave-error yes   # RDB后台保存失败后拒绝所有的写操作
rdbcompression yes                # 启用压缩功能

# AOF持久化配置
appendonly yes                    # 开启AOF持久化功能
appendfilename "appendonly.aof"   # 持久化文件名
# no: don't fsync, just let the OS flush the data when it wants. Faster.
# always: fsync after every write to the append only log. Slow, Safest.
# everysec: fsync only one time every second. Compromise.
appendfsync always                # 持久化模式


######## SECURITY ########
requirepass password              # 开启身份验证
rename-command CONFIG ""          # 重命名命令的名字 

######## REPLICATION ########
slaveof <masterip> <masterport>   # 配置该从节点的主节点
masterauth <master-password>      # 从节点向主节点发起验证
slave-serve-stale-data yes        # 
slave-read-only yes               # 从节点只读
# 当使用diskless同步策略时，在转换开始后，新到达的从节点将会被排队并等待下一次新的转换，为了提高传输的效率(同时向多个从节点传输)，主节点在开始传输之前会等待一段时间，期望获得更多的从节点
repl-diskless-sync no             # 主从同步的RDB文件是否写到磁盘上
repl-diskless-sync-delay 5        # 主节点开始传输之前等待的时间(秒)
# repl-ping-slave-period 10
# repl-timeout 60
repl-disable-tcp-nodelay no       # tcpnodelay 40毫秒延迟
repl-backlog-size 1mb             # 主从部分同步中积压缓冲区的大小
# repl-backlog-ttl 3600           # 最后一个从节点断开后多长时间后积压缓冲区被释放

slave-priority 100                # 从节点优先级 选举为主节点时使用

min-slaves-to-write 3             # 可用的slave最小数量
min-slaves-max-lag 10             # slave最大的交互时间间隔
# slave-announce-ip 5.5.5.5       
# slave-announce-port 1234        # 防止端口转发和NAT

######## ADVANCED CONFIG ########

client-output-buffer-limit normal 0 0 0
client-output-buffer-limit slave 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60    # 客户端输出缓冲区的限制

hz 10                             # serverCron函数 每秒执行次数
```

sentinel.conf

```
# bind 127.0.0.1 192.168.1.1
# protected-mode no            # 默认设置下只能对内访问，通过以上两个选项可设置
port 26379                                       # 端口
# sentinel announce-ip <ip>
# sentinel announce-port <port>                  # 防止端口转发和NAT

dir /tmp                                         # 工作目录
sentinel monitor mymaster 127.0.0.1 6379 2       # 客观下线的判断标准
# sentinel auth-pass <master-name> <password>    # 验证
sentinel down-after-milliseconds mymaster 30000  # 主观下线的判断标准
sentinel parallel-syncs mymaster 1               # 
sentinel failover-timeout mymaster 180000        # 

# sentinel notification-script mymaster /var/redis/notify.sh
# sentinel client-reconfig-script mymaster /var/redis/reconfig.sh # 自动化脚本配置
```