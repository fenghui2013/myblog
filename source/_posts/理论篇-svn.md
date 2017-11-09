---
title: 理论篇-svn
date: 2017-10-26 13:35:31
tags:
    - svn
---

svn主张"主干开发 分支发布"

记住当需要创建多个分支，特别分支是为了并行数个开发而不是发布时，往往意味着有些事情不对了。

解决冲突有两种方式: 悲观锁和乐观锁。svn使用乐观锁。


```
svn co remote_url local_project   # 签出仓库
svn commit -m "xxx"               # 签入仓库
svn update                        # 同步远程仓库
svn propset 
svn proplist
svn propget
svn propedit                      # 属性相关
svn copy -m "xxx" remote_url/trunk remote_url/tags/v0.1     # 创建标签
svn copy -m "xxx" remote_url/trunk remote_url/branches/v0.1 # 创建分支
svn move

svn revert                        # 恢复
svn resolved                      # 解决冲突
svn blame                         # 
```

忽略某些文件等功能都是使用属性实现的。

#### 二进制文件和锁

```
svn propset svn:needs-lock true xxx.txt     # 设置锁属性
svn lock xxx.txt -m "lock xxx.txt"          # 加锁 提交时自动解锁
svn unlock --force remote_url/xxx.txt       # 强制解锁
```

#### 标签和分支

命名规范

thing to name | name style | example
--------------|------------|--------
release branch| RB-rel     | RB-1.0
releases      | REL-rel    | REL-1.0
bug fix branches| BUG-track| BUG-3035
pre-bug fix | PRE-track    | PRE-3035
post-bug fix| POST-track   | POST-3035
developer experiments | TRY-initials-desc | TRY-MGM-cache-pages

标签和分支主要用于如下四个用途:

* 发布分支
* 发布
* bug修复
* 开发人员试验

bug修复，可借助标签功能。