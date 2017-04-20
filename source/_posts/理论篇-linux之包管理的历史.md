---
title: 理论篇-linux之包管理的历史
date: 2017-03-27 22:40:30
tags:
	- linux
	- apt
	- yum
---
### 包管理的历史
最初的软件包是tar.gz，人们将自己的程序打包，然后供别人免费下载使用。使用的人下载源码之后，解压，编译，使用。随着软件的发展，可用的软件越来越多，简单的打包已经不能满足人们对软件的管理，于是出现了包管理机制。

由于linux有[两大阵营](http://fenghui2013.github.io/2017/03/28/理论篇-计算机世界里的重要概念)，所以出现了两个包管理工具:rpm和dpkg。

#### RedHat阵营

##### rpm
rpm(RedHat Package Manager)是以RedHat为中心的包管理工具。

```
rpm -ivh package.rpm  # 安装
rpm -Uvh package.rpm  # 升级
rpm -ev  package      # 卸载
rpm -qlp package.rpm  # 查询包中的所有文件列表
rpm -qip package.rpm  # 查询包中的内容信息
rpm -qa               # 查询系统中所有已安装的rpm包
```

##### yum
由于rpm不支持依赖管理，所以每次使用rpm安装软件时，如果依赖其他包，需要我们手动下载安装依赖，显而易见，这样是很不方便的，于是yum(Yellowdog Updater Modified)出现了。yum在rpm的基础之上增加了自动更新和依赖关系管理。

```
yum search name     # 在软件包详细信息中搜索指定字符串
yum install name    # 向系统中安装一个或多个软件包
yum update name     # 更新系统中的一个或多个软件包
yum remove name     # 从系统中移除一个或多个软件包
yum erase name      # 从系统中移除一个或多个软件包
yum clean name      # 删除缓存的数据
```

##### rpm与yum

```
rpm --import key
yum install package.rpm
```


### 参考
* [学习 Linux，101: RPM 和 YUM 包管理](https://www.ibm.com/developerworks/cn/linux/l-lpic1-v3-102-5/)