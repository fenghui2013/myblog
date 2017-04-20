---
title: 实战篇-linux环境下网络相关的命令
date: 2017-03-26 22:01:43
tags:
	- linux
	- 网络
	- 命令
---
### 配置相关

```
chkconfig service on/off
```
### 网络相关
#### 查看网络连接
netstat -natp

参数含义

参数|含义
---|---
-n | 显示数字地址
-a | 显示所有监听和非监听的连接
-t | tcp协议
-p | 显示进程

#### 抓包工具
tcpdump -i eth0 host 127.0.0.1 and port 80 -s0 -w run.log

参数含义

参数|含义
----|---
-i  | 监听的接口
host| 主机
port| 端口
-s  | 设置快照的大小，默认为65535字节，0代表默认 
-w  | 写到文件