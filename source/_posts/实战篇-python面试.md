---
title: 实战篇-python面试
date: 2017-04-24 18:58:38
tags:
    - python
---

### 数据类型及变量

#### 引用
```
a = 1
def f(a):
    a = 2
f(a)
print a      # 1
-------------------
a = []
def f(a):
    a.append(1)
f(a)
print a      # [1]
```
涉及python中的引用以及可变量与不可变量的知识

#### 字符串格式化

```
name = "x"
"hi there %s" % name   # hi there x
name= ("x", )
"hi there %s" % (name, ) # hi there x

"hi there {0}".format(name)
```

```
class MyClass():
    def __init__(self):
        self.__superprivate = "hello"
        self._semiprivate = "world"

    def f(self):
        print self.__superprivate


mc = MyClass()
print mc.__dict__
print mc._semiprivate
mc.f()
print mc.__superprivate


--------output--------
{'_MyClass__superprivate': 'hello', '_semiprivate': 'world'}
world
hello
Traceback (most recent call last):
  File "test.py", line 32, in <module>
    print mc.__superprivate
AttributeError: MyClass instance has no attribute '__superprivate'
```

* \_\_foo\_\_: 一种约定，python内部的名字，用来区别用户自定义的名字，以防冲突
* \_foo: 一种约定，程序员用来指定私有变量的形式
* \_\_foo: 真正的私有变量，会变成_classname__foo

### 类相关

#### 类的各种方法

```
def foo(x):
    print("foo %s" % x)
    
class A(object):
    def foo(self, x):
        print("foo %s %s", self, x)
    
    @classmethod
    def class_foo(cls, x):
        print("class_foo %s %s", cls, x)
        
    @staticmethod
    def static_foo(x):
        print("static_foo %s", x)
```

\      | 实例方法  |   类方法        | 静态方法
-------|---------|----------------|-------------
a = A()| a.foo(x) | a.class_foo(x) | a.static_foo(x)
A      |  不可用   |  A.class_foo(x) | A.static_foo(x)

实例方法的本质是foo(a, x)，类方法的本质是class_foo(A, x)，静态方法的本质是普通方法，只是作用域不同

#### 类的各种变量

```
class Person:
    name = "aaa"
    
p1 = Person()
p2 = Person()
p1.name = "bbb"
print p1.name     # bbb
print p2.name     # aaa
print Person.name # aaa
-----------------------
class Person:
    name = []
p1 = Person()
p2 = Person()
p1.name.append(1)
print p1.name    # [1]
print p2.name    # [1]
```

### 自省机制

自省就是程序执行时能知道对象的类型。

```
type()
dir()
getattr()
hasattr()
isinstance()
```

### 推导式

```
[x for x in xrange(3)]    # [0, 1, 2]
[x for x in xrange(10) if x%2 == 0]  # [0, 2, 4, 6, 8]
[[x, y] for x in xrange(2) for y in xrange(2)]  # [[0, 0], [0, 1], [1, 0], [1, 1]]

{key: value for (key, value) in iterable}
```

### 迭代器与生成器

```

```