---
title: 实战篇-ssh
date: 2017-04-11 21:29:53
tags:
	- ssh
---
### 认证原理

```
A----发送公钥--->B(若A的公钥在B的认证列表里，则省略密码验证部分)
A<---发送公钥----B
A----使用B公钥加密后的密码---->B
A<---通过后连接建立----B
```

### 免密登录
原理: 假如想从A免密登录B，需要在A上生成一个.ssh/id_rsa.pub，然后拷贝到B的.ssh/authorized_keys。

```
A:
ssh-key-gen
ssh-copy-id B
```

### ssh翻墙

```
ssh -qTfnN -D port user@host
```