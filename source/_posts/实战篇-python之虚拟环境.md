---
title: 实战篇-python之虚拟环境
date: 2017-05-13 09:44:51
tags:
    - python
---

实际工作中，我们经常会遇到这样的场景: 维护多个python项目，每个项目依赖的第三方库又不同。在一台机器上面，很难应对这样的场景。但是，今天我们介绍一款应对此场景的利器: virtualenv。

virtualenv是创建python虚拟环境的工具。

#### 安装

```
# pip源码安装
wget https://bootstrap.pypa.io/get-pip.py
sudo python get-pip.py

# virtualenv安装
sudo pip install virtualenv
```

#### 使用


```
若想在虚拟环境为
```

```
virtualevn ENV  # 创建一个虚拟环境
    --no-site-packages  # 不实用系统环境中的第三方库

deactivate      # 退出当前环境
```


#### 参考

[pip官网](https://pip.pypa.io/en/latest/installing/#python-and-os-compatibility)