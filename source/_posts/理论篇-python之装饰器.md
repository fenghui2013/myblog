---
title: 理论篇-python之装饰器
date: 2017-05-05 20:47:09
tags:
    - python
---

### 装饰器
装饰器提供了一种插入在函数和类定义完成之后自动运行代码的方法。python里面装饰器有两种: 1.函数装饰器 2.类装饰器。装饰器共有两种用途: 1. 管理函数调用和实例创建 2. 管理函数和类

装饰器使代码更易维护和美观，如果不使用装饰器，这些功能也可实现。

#### 函数装饰器
函数装饰器其本质是在函数定义完成之后自动运行另一个函数，把原函数重新绑定到其他可调用对象上。

```
# 管理函数
def decorator(F):
    # process functions F
    return F

@decorator
def func(): ...

# 管理函数调用
def decorator(F):
    # save or use function F
    # return a different callable: nested def, class with __call__, etc
    def wrapper(*args):
        # use F and args
        # F(*args) calls original function
    return wrapper
    
@decorator
def func(x, y): ...

func(6, 7)
```
