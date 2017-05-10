---
title: 理论篇-tornado之netutil
date: 2017-05-10 09:07:26
tags:
---

网络工具包

函数| 功能 | 特别说明
---|------|--------
bind_sockets(port, address=None, family=<AddressFamily.AF_UNSPEC: 0>, backlog=128, flags=None, reuse_port=Flase)| 创建监听socket
bind_unix_socket(file, mode=384, backlog=128)| 创建一个监听的unix socket
add_accept_handler(sock, callback, io_loop=None)| 增加一个IOLoop的事件处理器来接收新的连接
is_valid_ip(ip)| 检测ip地址合法性
Resolver| 异步dns解析接口