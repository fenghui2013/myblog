---
title: 理论篇-gitlab
date: 2017-10-19 15:27:16
tags:
    - gitlab
---

### gitlab架构

使用的组件及功能

* nginx: 主要负责请求路由及一些静态资源的访问
* database: 持久化数据，比如(issues, merge requests etc)
* redis: task的缓存队列
* sidekiq: 主要负责发送邮件，从redis中接收task
* unicorn: 一个ruby系的http框架，即我们的gitlab
* gitlab-shell: 负责处理ssh协议的请求
* gitaly: 执行所有来自http或ssh的git操作

#### gitaly

gitaly是一个git rpc服务，用来处理所有gitlab产生的git操作。实现如下两个目标:

* 让git操作离数据更近
* 使用缓存或其他技术优化git服务

#### gitlab问题列表

>remote gitlab you are not allowed to push code to protected branches on this project

该分支只能push request，然后由专人负责merge。不能直接push。

### gitlab高可用

#### 文件和数据库备份

```
# backup
gitlab-rake gitlab:backup:create
# restore
gitlab-rake gitlab:backup:restore
```

#### 从快照中恢复

从快照中恢复比从备份中恢复要快。

#### 多应用服务