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
函数装饰器:装饰函数的装饰器

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
类装饰器:装饰类的装饰器
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

#有问题的写法
class Decorator:
    def __init__(self, C):
        self.C = C
    def __call__(self, *args):
        self.wrapped = self.C(*args)
        return self
    def __getattr__(self, attrname):
        return getattr(self.wrapped, attrname)

@Decorator
class C: ...

x = C()
y = C()
```

#### 装饰器嵌套

```
@A
@B
@C
def f():
    pass

f = A(B(C(f)))

@A
@B
class C:
    pass
    
C = A(B(C))
```

#### 装饰器参数
本质是首先执行一个函数，该函数返回一个装饰器。

```
def decorator(A, B):
    # save or use A, B
    def actualDecorator(F):
        # save or use function F
        # return a callable, nested def, class with __call__ etc
        return callable
    return actualDecorator
    
@decorator(A, B)
def F(arg):
    ...

等价于
F = decorator(A, B)(F)
    
F(99)
```

#### 保持状态信息的地方

* 类实例属性
* 全局作用域
* 封闭作用域 nonlocal(3.x)
* 函数属性

#### 待深究

* 使用描述符装饰方法(38章 类错误之一:装饰类方法)

#### 函数装饰器VS类装饰器
仔细分析一下代码，一个retry是类装饰器，一个是函数装饰器，都能成功吗？为什么？

**结论**: 基于函数的装饰器既可以装饰函数也可以装饰方法，基于类的装饰器只能装饰函数

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

#### 进阶篇

使用装饰器有很多优点，但是也带来了一个很让人头痛的问题，就是debug。比如看下面的代码

```
def decorator(func):
    #@wraps(func)
    def _wrapper(*args):
        func(*args)
    #_wrapper.__name__ = func.__name__
    return _wrapper

@decorator
def f():
    print("hello world")

print(f.__name__)
----output----
1. 不使用装饰器的情况下，输出f
2. 使用装饰器的情况下，输出_wrapper
3. 使用@wraps的情况下，输出f

wraps将被包装函数的属性赋值给了包装函数，给调试带来了便利。
```

#### 注意点
* 装饰器只执行一次，在**函数或类定义**的时候，记住不是调用的时候
* 装饰函数的装饰器是函数装饰器，装饰类的装饰器是类装饰器。函数和类装饰器有两种形式:基于函数的装饰器和基于类的装饰器
* 装饰器的本质是接收一个被包装的函数，返回一个接收参数的可调用对象。
* 带参数的装饰器的本质是首先执行一个函数，然后返回一个装饰器