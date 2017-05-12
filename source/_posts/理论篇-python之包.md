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
import xxx1.xxx2 as mod   # 导入模块
```

#### 相对导入