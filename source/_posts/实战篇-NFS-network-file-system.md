---
title: 实战篇-NFS(network file system)
date: 2017-10-23 16:04:04
tags:
    - 文件系统
---

### NFS

NFS(network file system)主要是为了让不同的机器、不同的系统间共享数据。通常作为文件服务器来使用。

#### 组成

NFS由许多服务组成，所以需要占用很多端口，故需要RPC服务来告知客户端各个服务的端口信息。RPC服务的端口固定为: 111

**备注:**启动NFS服务的时候，先启动RPC服务。因为NFS服务需要向RPC服务注册端口号。

* rpc.nfsd
    
    验证用户登录权限
* rpc.mounted

    验证用户对文件的访问权限(-rwxrwxrwx owner group)
* rpc.lockd

    管理文件的锁定状态，防止多用户写入
* rpc.statd

    检查文件的一致性
    
#### 命令