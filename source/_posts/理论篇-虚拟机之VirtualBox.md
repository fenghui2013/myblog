---
title: 理论篇-虚拟机之VirtualBox
date: 2017-09-03 18:29:19
tags:
    - virtualbox
---

#### 网络连接

virtualbox提供了四种网络连接方式

* NAT
* Bridged Adapter
* Internal
* Host-only Adapter

各个方式之间的区别

   | NAT | Bridged Adapter | Internal | Host-only Adapter
---|-----|-----------------|----------|------------------
虚拟机->主机| Y | Y | N | 默认不能 需设置
主机->虚拟机| N | Y | N | 默认不能 需设置
虚拟机->其它主机| Y | Y | N | 默认不能 需设置
其它主机->虚拟机| N | Y | N | 默认不能 需设置
虚拟机之间| N | Y | 同网络名下可以 | Y


NAT模式下可以通过端口转发，将宿主机端口映射到虚拟机中的某个端口来访问虚拟机中的某个服务。