---
title: 理论篇-python之包
date: 2017-05-12 15:42:16
tags:
---

python将操作系统中的目录变成了包，本质也是一种命名空间，主要为了防止命名冲突。

包含\_\_init\_\_.py文件的目录就是python的包。


* 包初始化: 包第一次被初始化的时候会执行\_\_init\_\_.py的代码
* 模块命名空间初始化: \_\_init\_\_.py里的变量会变成模块对象的属性
* from *: 加载\_\_all\_\_列表里的内容

```
__all__                   # from *需加载的内容
from xxx1.xxx2 import mod # 导入模块
import xxx1.xxx2 as mod   # 给模块起个别名
```

#### 相对导入

* 相对导入只针对包内搜索
* 目的是解决包导入时的歧义性
* 2.6及以后的搜索方式: 先相对后绝对。3.x及以后搜索绝对路径(sys.path)，除非显式指定相对搜索

```
. ..                        # 相对导入符号
from string import name     # 从绝对路径搜索 
from .string import test    # 2.x 3.x 从当前包路径搜索
import test         # 2.x首先搜索当前包，然后搜索绝对路径 3.x搜索绝对路径

from __future__ import absolute_import   # 2.x搜索绝对路径
```

#### 模块的私有属性

```
_name  # 一种约定，只对from *有效
```

#### 最新功能的使用

```
from __future__ import featurename
```