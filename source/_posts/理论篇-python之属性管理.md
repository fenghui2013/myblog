---
title: 理论篇-python之属性管理
date: 2017-05-23 16:38:28
tags:
    - python
---

```
__getattr__       # 路由所有未定义属性的访问
__setattr__       # 路由所有属性赋值到一般处理方法

__getattribute__  # 路由所有属性访问到一般处理方法(2.6之后和3.x)

property          # 路由特定的属性访问到get和set处理方法 properties
descriptor protocol # routing specific attribute access to instances of classes with arbitrary get and set handler methods.
```

属性协议允许我们路由一个特定的属性的get和set操作到我们提供的函数或方法上，使用我们能够插入在属性访问时自动运行的代码，拦截属性删除和为属性提供文档等。