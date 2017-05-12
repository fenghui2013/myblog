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

方法| 重载 | 调用
----|-----|-----
\_\_new\_\_|创建|在\_\_init\_\_之前创建对象
\_\_init\_\_|构造函数|对象建立: x = Class(args)
\_\_del\_\_|析构函数| x对象收回\_\_call\_\_|函数调用 x(\*args, **kwargs)
\_\_delete\_\_||
\_\_dict\_\_|属性字典，实例调用时只返回实例属性 类调用时只返回类属性|
\_\_slots\_\_||
\_\_class\_\_|实例所属的类的链接|
\_\_bases\_\_|实例超类引用的元组|
\_\_getattr\_\_|获得属性(针对未定义的属性) 点号运算|
\_\_setattr\_\_|属性赋值运算|
\_\_delattr\_\_|属性删除运算 
\_\_getattribute\_\_|获得属性(针对所有属性)|
\_\_and\_\_|与运算| 1 and 2
\_\_or\_\_|或运算| 1 or 2
\_\_str\_\_|适合人读取的信息， 当没有实现时，返回repr的内容|pirnt(x) repr(x) str(x)
\_\_repr\_\_|适合机器读取的信息|
\_\_getiiem\_\_|索引运算|x[key], x[i:j], 没__iter__时的for循环和其他迭代器
\_\_setitem\_\_|索引赋值语句|x[key]=value x[i:j]=sequence
\_\_delitem\_\_|索引和分片删除|del x[key], del x[i:j]
\_\_len\_\_|长度|len(x), 如果没有\_\_bool\_\_, 真值测试
\_\_bool\_\_|布尔测试|bool(x), 真测试，在2.6中是\_\_nonzero\_\_
\_\_lt\_\_,\_\_gt\_\_||
\_\_le\_\_,\_\_ge\_\_||
\_\_eq\_\_,\_\_ne\_\_|特定的比较|x<y, x>y, x<=y, x>=y, x==y, x!=y 在2.6中只有\_\_cmp\_\_
\_\_radd\_\_|右侧加法|other + x
\_\_iadd\_\_|实地加法|x + y
\_\_iter\_\_, \_\_next\_\_|迭代环境|I=iter(x), next(I); for loops
\_\_contains\_\_|成员关系测试|item in x
\_\_index\_\_|整数值|
\_\_enter\_\_, \_\_exit\_\_|环境管理器|with obj as var:
\_\_get\_\_, \_\_set\_\_|描述符属性|x.attr, x.attr=value, del x.attr
\_\_index\_\_|返回某一个实例的整数值|hex(x), bin(x), oct(x)

```
# 分片语法本质是一个分片对象slice的实例
l = [5, 6, 7, 8, 9]
print(l[::2])
print(l[slice(None, None, 2)])

class Indexer:
    data = [5, 6, 7, 8, 9]
    def __getitem__(self, index):
        print("__getitem__: %s" % index)
        return self.data[index]

    def __setitem__(self, index, value):
        self.data[index] = value

    def __len__(self):
        return len(self.data)

x = Indexer()
print(x[2])
print(x[::2])
print(x[:])
x[:] = [1, 2, 3]
print(x[:])

-------output--------
[5, 7, 9]
[5, 7, 9]
__getitem__: 2
7
__getitem__: slice(None, None, 2)
[5, 7, 9]
__getitem__: slice(0, 9223372036854775807, None)
[5, 6, 7, 8, 9]
__getitem__: slice(0, 9223372036854775807, None)
[1, 2, 3]

# __getitem__
class steper:
    data = "tom"
    def __getitem__(self, i):
        print("__getitem__: %s" % i)
        return self.data[i]

x = steper()
print(x[1])
#----for----
for item in x:
    print(item)
#----in----
print('o' in x)
#----list comprehension----
print([c for c in x])
print(map(str.upper, x))

# 任何支持for循环的类也会支持python所有的迭代环境

# __iter__ __next__(2.x中是next)
迭代环境优先使用__iter__，退而求其次使用__getitem__
class Squares():
    def __init__(self, start, stop):
        self.value = start - 1
        self.stop = stop

    def __iter__(self):
        return self

    def next(self):
        if self.value == self.stop:
            raise StopIteration
        self.value += 1
        return self.value ** 2

for i in Squares(1, 5):
    print(i)


# __index__
class C:
    def __index__(self):
        return 255

c = C()
print(c)
print(bin(c))
----output----
<__main__.C instance at 0x10578a5f0>
0b11111111

# __del__
class Life:
    def __init__(self, name='unknown'):
        print('hello %s' % name)
        self.name = name

    def __del__(self):
        print('goodbye %s' % self.name)

t = Life('tom')
t = 'xxx'          # call __del__
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
iter()      # 获取一个迭代对象
```

#### 新式类

在python2.2之后包含了一种新式类，3.x里类得到了统一，都是新式类。

```
class C:     # classic class
    ...
    
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

#### 个人感悟

* 类的本质是字典
* 方法调用的本质是类作用域下的函数的调用
* 点号引用变量会触发python的树搜索机制
* python中的类只是通过class关键字声明了一个类对象。通过类对象可以创建实例对象。类对象和实例对象本质都是命名空间。通过树搜索机制实现继承，通过内部的分发机制实现运算符重载。