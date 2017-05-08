---
title: 理论篇-python之类
date: 2017-05-07 14:34:15
tags:
    - python
---

### 类

> By and large, OOP is about looking up attributes in trees with a special first argument in functions.

> design patterns, common OOP structures

类声明是在类所在的模块文件被加载时执行的。

继承树的结构与类声明时父类出现的顺序有关，属性的查找顺序是有下至上，从左到右。

运算符重载函数(比如\_\_init\_\_)不是内建函数或保留字，它们仅是当对象出现在各种上下文时python寻找的属性。运算符重载应该与内置运算符实现工作一致。

命名空间对象的属性通常使用字典实现，类继承树仅仅是链接到其他字典的字典。

#### 类的主要特性:

* The class statement creates a class object and assigns it a name
* Assignemnts inside class statements make class attributes.
* Class attributes provide object state and behavior.

#### 实例的主要特性:

* Calling a class object like a function makes a new instance object.
* Each instance object inherits class attributes and gets its own namespace.
* Assignments to attributes of self in methods make per-instance attributes.

#### 继承的关键点:

* Superclasses are listed in parentheses in a class header.
* Classes inherit attributes from their superclasses.
* Instances intherit attributes from all accessible classes.
* Each object.attribute reference invokes a new, independent search.
* Logic changes are made by subclassing, not by changing superclasses.

#### 运算符重载的关键点:

* Methods named with double underscores(\_\_x\_\_) are special hooks.(python defines a fixed and unchangeable mapping from each of these operations to a specially named method)
* Such operations are called automatically when instances appear in built-in operations.
* Classes may override most bulit-in type operations.
* There are no defaults for operator overloading methods, and none are required.
* New-style classes have some defaults, but not for common operations.
* Operations allow classes to integrate with Python's object model. 

可重载的运算符:

```
# 方法
__init__                 # 构造函数
__del__                  # 析构函数
__and__                  # &
__or__                   # ||
__str__                  # 适合人读取的信息， 当没有实现时，返回repr的内容
__repr__                 # 适合机器读取的信息
__call__                 # 函数调用
__dict__()               # 属性字典，实例调用时只返回实例属性 类调用时只返回类属性
__slots__(self)
__class__(self)          # 实例所属的类的链接
__bases__(self)          # 实例超类引用的元组
__getattr__(self)        # 获得属性(针对未定义的属性) 点号运算
__setattr__              # 属性赋值运算
__delattr__              # 属性删除运算 
__getattribute__(self)   # 获得属性(针对所有属性)
# 属性
__name__
```

#### 私有方法或变量
单下划线开头的变量或方法只是一种约定，双下划线开头的变量或方法会将类信息加入到函数名中，是一种真正的私有化。
```
_name
_method  # 约定
__name
__method # 等价于class_name class_method
```

#### 抽象超类
抽象超类的含义如下:

```
class Super:               # Super是抽象超类
    def method(self):
        print("in Super.method")

    def delegate(self):
        self.action()   # expected to be defined
        
    def action(self):
        #assert False, "action must be defined"
        raise NotImplementedError("action must be defined")
        
class Provider(Super):
    def action(self):
        print("in Provider.action")

p = Provider()
p.delegate()
```
python提供的抽象超类的定义:

```
# 2.6
from abc import ABCMeta, abstractmethod

class Super():
    __metaclass__ = ABCMeta
    @abstractmethod
    def method(self):
        pass

s = Super()

# 3.0
from abc import ABCMeta, abstractmethod

class Super(metaclass = ABCMeta):
    @abstractmethod
    def method(self):
        pass

s = Super()
```


```
# 属性
class T():
    a = "hello"          # 类属性
    def setB(self, b):
        self.b = b       # 实例属性
 
# 方法        
instance.method(args...) == class.method(instance, args...)

# 子类调用父类的构造函数
class Super:
    def __init__(self, x):
        self.x = x

class Sub(Super):
    def __init__(self, x, y):
        Super.__init__(self, x)
        self.y = y

x = Sub(1, 2)
```

```
# 使用自省机制实现通用的功能
class AttrDisplay:
    def gatherAttrs(self):
        attrs = []
        for key in sorted(self.__dict__):
            attrs.append("%s=%s" % (key, getattr(self, key)))
        return ', '.join(attrs)

    def __str__(self):
        return "[%s: %s]" % (self.__class__.__name__, self.gatherAttrs())


if __name__ == "__main__":
    class TopTest(AttrDisplay):
        count = 0
        def __init__(self):
            self.attr1 = TopTest.count
            self.attr2 = TopTest.count + 1
            TopTest.count += 2
    class SubTest(TopTest): pass

    x, y = TopTest(), SubTest()
    print(x)
    print(y)
```

#### 特殊函数

```
dir()       # 查看某一个对象的所有属性
```

#### 个人感悟

* 类的本质是字典
* 方法调用的本质是类作用域下的函数的调用
* 点号引用变量会触发python的树搜索机制
* python中的类只是通过class关键字声明了一个类对象。通过类对象可以创建实例对象。类对象和实例对象本质都是命名空间。通过树搜索机制实现继承，通过内部的分发机制实现运算符重载。