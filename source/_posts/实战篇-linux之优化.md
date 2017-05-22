---
title: 实战篇-linux之优化
date: 2017-05-21 15:18:47
tags:
    - linux
---

```
# 对tcp各个状态的连接进行统计
netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'
```

```
# somaxconn
echo 2048 >   /proc/sys/net/core/somaxconn  # 临时修改最大连接数
```

```
# /etc/sysctl.conf
# core
net.core.somaxconn = 2048   # 最大连接数 listen的backlog

# tcp
# 开启syn cookies。当出现syn等待队列溢出时，启用cookies来处理，可防范少量syn攻击，默认为0
net.ipv4.tcp_syncookies=1
# 开启重用。允许将TIME-WAIT sockets重新用于新的连接，默认为0
net.ipv4.tcp_tw_reuse=1
# 开启快速回收，默认为0
net.ipv4.tcp_tw_recycle=1
# 修改系统默认的timeout
net.ipv4.tcp_fin_timeout=30

# 建议在流量非常大的服务器上开启
# tcp发送keepalive消息的频率，默认为2小时
net.ipv4.tcp_keepalive_time=1200
# 可用的建立连接的端口范围 默认为32768~61000
net.ipv4.ip_local_port_range=10000 65000
# syn队列的长度，默认为1024
net.ipv4.tcp_max_syn_backlog=8192
# time wait的最大数量，默认为18000
net.ipv4.tcp_max_tw_buckets=6000


#net.core.netdev_max_backlog = 32768

sysctl -p                   # 使配置生效
```