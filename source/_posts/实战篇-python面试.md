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

#### is与==

```
is比较引用地址
==比较值
```

### 类相关

#### \_\_new\_\_与\_\_init\_\_
* \_\_new\_\_是一个类方法，\_\_init\_\_是一个实例方法
* \_\_new\_\_返回一个创建的实例，\_\_init\_\_什么都不返回
* \_\_new\_\_执行后\_\_init\_\_才执行

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

#### 单例

[参看源码](https://github.com/fenghui2013/myblog_source/blob/master/python/language_test/singleton_test.py)

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
mylist = [1, 2, 3]
for i in mylist:
    print i
for i in mylist:
    print i

mygenerator = (x for x in range(3))
for i in mygenerator:
    print i
for i in mygenerator:
    print i
    
---- output ----
1
2
3
1
2
3
0
1
2
```
* 迭代器的本质是: \_\_iter\_\_和\_\_next\_\_
* 生成器的本质是: yield

### 函数
\*args和\*\*kwargs

```
def print_everything(*args):
    for count, thing in enumerate(args):
        print '{0} {1}'.format(count, thing)

print_everything('apple', 'banana', 'cabbage')

def table_things(**kwargs):
    for key, value in kwargs.items():
        print '{0}={1}'.format(key, value)

table_things(apple='fruit', cabbage='vegetable')
---- output ----
0 apple
1 banana
2 cabbage
cabbage=vegetable
apple=fruit
```

#### 装饰器
```
def makebold(fn):
    def wrapped():
        return '<b>' + fn() + '</b>'

    return wrapped

def makeitalic(fn):
    def wrapped():
        return '<i>' + fn() + '</i>'

    return wrapped

@makebold
@makeitalic
def say():
    return 'hello world'

print say()
---- output ----
<b><i>hello world</i></b>
```

#### 闭包
* 必须有一个内嵌函数
* 内嵌函数必须引用外部函数中的变量
* 外部函数的返回值必须是内嵌函数

#### lambda表达式

```
f = lambda x, y, z: x+y+z
f(1, 2, 3)  # 6
```

#### 函数式编程

```
print filter(lambda x: x>5, [1, 2, 3, 4, 5, 6, 7])
print map(lambda x: x**2, [1, 2, 3, 4, 5, 6, 7])
print reduce(lambda x, y: x*y, range(1, 4))
---- output ----
[6, 7]
[1, 4, 9, 16, 25, 36, 49]
6
```

### 鸭子类型
### 作用域
* 本地作用域(local)
* 当前作用域被嵌入的作用域(enclosing local)
* 全局/模块作用域(global)
* 内置作用域(built-in)

### 全局解释器锁(GIL)
### 协程
### 拷贝

```
import copy
a = [1, 2, 3, 4, ['a', 'b']]

b = a
c = copy.copy(a)
d = copy.deepcopy(a)

a.append(5)
a[4].append('c')

print a
print b
print c
print d
---- output ----
[1, 2, 3, 4, ['a', 'b', 'c'], 5]
[1, 2, 3, 4, ['a', 'b', 'c'], 5]
[1, 2, 3, 4, ['a', 'b', 'c']]
[1, 2, 3, 4, ['a', 'b']]
```

### 垃圾回收机制

GC主要使用引用计数(reference counting)来跟踪和回收垃圾。在引用计数的基础上通过"标记-清除"(mark and sweep)解决容器对象可能产生的循环引用问题，通过"分代回收"(generation collection)以空间换时间的方法提高垃圾回收效率。

#### 引用计数
PyObject是每个对象必有的内容，其中ob_refcnt就是引用计数器。当一个对象有新的引用时，ob_refcnt就增加，当引用它的对象被删除时，ob_refcnt就减少。引用计数器为0时，该对象的生命就结束了。

* 优点
    * 简单
    * 实时性
* 缺点
    * 维护引用计数消耗资源
    * 循环引用

#### 标记-清除机制
基本思路是先按需分配，等内存空间不够时从寄存器或程序栈上的引用出发，遍历以对象为节点，以引用为边构成的图，把所有可访问的对象打上标记，然后清扫一遍内存空间，把所有没标记的对象清除。

#### 分代回收
分代回收的基本思想: 将系统中的所有内存块根据其存活时间分为不同的集合，每个集合就成为一个代，垃圾回收频率随着“代”的存活时间的增大而减小，存活时间通常利用经过几次垃圾回收来衡量。

