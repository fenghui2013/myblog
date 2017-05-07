---
title: 理论篇-python之装饰器
date: 2017-05-05 20:47:09
tags:
    - python
---

### 装饰器
装饰器提供了一种插入自动运行代码(在**函数和类定义**完成之后)的方法。python里面装饰器有两种: 1.函数装饰器 2.类装饰器。装饰器共有两种用途: 1. 管理函数调用和实例创建 2. 管理函数和类

装饰器使代码更易维护和美观，如果不使用装饰器，这些功能也可实现。

#### 函数装饰器
函数装饰器其本质是在函数定义完成之后自动运行另一个函数，把原函数重新绑定到其他可调用对象上。主要用途: 1. 装饰函数或方法, 2. 管理函数。

```
# 管理函数
def decorator(F):
    # process functions F
    return F

@decorator
def func(): ...            # func = decorator(func)

# 管理函数调用
def decorator(F):
    # save or use function F
    # return a different callable: nested def, class with __call__ etc
    def wrapper(*args):
        # use F and args
        # F(*args) calls original function
    return wrapper
    
@decorator
def func(x, y): ...

func(6, 7)
本质: func = decorator(func) 此时func指向wrapper。

class decorator:
    def __init__(self, f):
        self.f = f
    def __call__(self, *args):
        self.f(*args)
        
@decorator
def func(x, y): ...

func(6, 7)
本质: func = decorator(func) 此时func是decorator的一个实例，该实例又是可被调用的
```

####  类装饰器
主要用途: 1. 管理实例的创建 2. 管理类

```
# 管理类
def decorator(C):
    # process class C
    return C
    
@decorator
class C: ...              # C = decorator(C)

# 管理实例创建
def decorator(C):
    # save or use class C
    # return a different callable: nested def, class with __call__ etc

@decorator
class C: ...              # C = decorator(C)


def decorator(cls):
    class Wrapper:
        def __init__(self, *args):
            self.wrapped = cls(*args)

        def __getattr__(self, name):
            return getattr(self.wrapped, name)
    return Wrapper


@decorator
class C:
    def __init__(self, x, y):
        self.attr = 'spam'

c = C(6, 7)
print(c.attr)
```

#### 函数装饰器VS类装饰器
仔细分析一下代码，一个retry是类装饰器，一个是函数装饰器，都能成功吗？为什么？

**结论**: 函数装饰器既可以装饰函数也可以装饰方法，类装饰器只能装饰函数

```
class retry():
    def __init__(self, f):
        print("init before")
        self.f = f
        print("init after")
    def __call__(self, *args):
        print("call before")
        self.f(*args)
        print("call after")

#def retry(f):
#    def _f(*args):
#        f(*args)
#    return _f

@retry
def f(x, y):
    print("function:x + y = %s" % (x+y))

class T:
    @retry
    def f(self, x, y):
        print("method:x + y = %s" % (x+y))

f(1, 2)
f(2, 3)

t = T()
t.f(1, 2)
t.f(2, 3)


# 给点提示
def f2(x, *args):
    print(len(args))

f2(1)
f2(1, 2)
f2(1, 2, 3)
```

#### 注意点
* 装饰器只执行一次，在**函数或类定义**的时候，记住不是调用的时候