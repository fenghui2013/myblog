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

继承树的结构与类声明时父类出现的顺序有关，属性的查找顺序是由下至上，从左到右。

运算符重载函数(比如\_\_init\_\_)不是内建函数或保留字，它们仅是当对象出现在各种上下文时python寻找的属性。运算符重载应该与内置运算符实现工作一致。

命名空间对象的属性通常使用字典实现，类继承树仅仅是链接到其他字典的字典。

#### 类的主要特性:

* class语句创建了一个class对象，并且分配了一个名字
* class内的赋值语句创造了类属性
* 类属性提供了对象状态和行为

#### 实例的主要特性:

* 像函数一样调用类对象将创建一个实例
* 每个实例对象继承了类属性并得到了自己的命名空间
* 方法里对self属性的赋值创造了每个实例的属性

#### 继承的关键点:

* 超类写在class语句的括号里
* 类继承它们超类的属性
* 实例从所有可访问的类中继承属性
* 每个属性的引用将触发一个新的独立的搜索
* 子类里的实现不会影响到父类

#### 运算符重载的关键点:

* 带有双下划线的方法名是特殊的钩子(python定义了一个固定的操作符到特殊方法名之间的映射关系)
* 当实例出现在内建的操作中时，相应的操作被自动调用
* 类可以覆盖大多数内建类型的操作
* There are no defaults for operator overloading methods, and none are required.
* New-style classes have some defaults, but not for common operations.
* Operations allow classes to integrate with Python's object model.

#### 私有方法或变量
单下划线开头的变量或方法只是一种约定，双下划线开头的变量或方法会将类信息加入到函数名中，是一种真正的私有化。

```
_name
_method  # 约定
__name
__method # 等价于class_name class_method
```

#### 方法的两种调用方式: 绑定与未绑定

类中的方法有两种调用方法:1. 绑定实例调用 2. 未绑定实例调用

```
class C:
    def test(self, name):
        print(name)
        
c = C()
x = c.test
x("xxx")      # 绑定实例调用

x = C.test
x(c, "xxx")   # 未绑定实例调用

3.x中取消了未绑定方法，统一为函数:

class C:
    def test1(self, name):
        print(name)
        
    def test2(name):
        print(name)
        
c = C()
C.test2("xxx")     # 函数调用 fail in 2.6
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

#### 旧式类

```
class C:     # classic class
    ...
```
传统类的搜索方式: 深度优先，从左到右，简称DFLR

#### 新式类

在python2.2之后包含了一种新式类，3.x里类得到了统一，都是新式类。

```
class C(object):  # new-style class
    ...
```

不同点:

* \_\_getattr\_\_和\_\_getattribute\_\_不支持隐式的内置属性的访问
* 对于内建类型属性的获取跳过实例，从类开始
    
    原因:
    
    * 为了效率考虑，对于内建类型的访问直接从类开始，省去了从实例搜索的步骤
    * 从整个模型的一致性考虑，类是元类的实例，实例是类的实例。元类可以定义自己的内建属性来处理类，类可以定义自己的内建属性来处理实例。
    
    影响:
    
    * 基于委托模式实现的代码

    解决方案: 即实现\_\_getattr\_\_为了正常属性的访问，也实现那些需要访问的内建属性
    
    ```
    class C:
        def __getitem(self, i):
            ...
            
    c = C()
    c["name"]  # 在传统类中等价于c.__getitem__("name"),在新式类中等价于C.__getitem__(c, "name")
    ```

* type模型的改变: class是type的实例，它的类型是type。实例是class的实例，它的类型是class
    
    ```
    class C: pass
    print(type(C), type(C()))     # (<type 'classobj'>, <type 'instance'>)
    
    class C(object): pass
    print(type(C), type(C()))     # (<type 'type'>, <class '__main__.C'>)
    ```
    
* 所有的类派生自object

    * 传统类的搜索方式: 深度优先，从左到右，简称DFLR
    * 新式类的搜索方式: 广度优先，从左到右，简称MBR

    ```
    class A: attr = 1
    class B(A): pass
    class C(A): attr = 2
    class D(B, C): pass
    
    x = D()
    x.attr     # search order: x D B A C
    
    class A(object): attr = 1
    class B(A): pass
    class C(A): attr = 2
    class D(B, C): pass
    
    x = D()
    x.attr     # search order: x D B C A
    ```
    
    
##### 新式类的扩展功能

##### slots
该功能可以优化内存和访问速度。

拥有\_\_slots\_\_属性的类默认没有\_\_dict\_\_属性，其他基于\_\_dict\_\_属性的方法使用\_\_slots\_\_代替。

```
class Person(object):
    __slots__ = ['name', 'age', 'job']   # 限制实例拥有的属性

p = Person()
p.sex = "xxx"         # error
    
# 增加__dict__
class Person(object):
    __slots__ = ['name', 'age', 'job', '__dict__']
    
p = Person()
p.sex = "xxx"         # ok
```

**备注:** 只能限制实例属性，不能限制类属性

#### 个人感悟

* 类的本质是字典
* 方法调用的本质是类作用域下的函数的调用
* 点号引用变量会触发python的树搜索机制
* python中的类只是通过class关键字声明了一个类对象。通过类对象可以创建实例对象。类对象和实例对象本质都是命名空间。通过树搜索机制实现继承，通过内部的分发机制实现运算符重载。


#### 待研究

python中，type继承自object，object继承自type，尽管这两个是两个不同的对象。type是生成class的类型。