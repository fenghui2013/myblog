---
title: 理论篇-python之元类
date: 2017-06-01 08:42:25
tags:
    - python
---

元类在class语句执行完之后自动执行。

元类的主要工作: 通过声明一个元类，我们告诉python路由类对象的创建到我们提供的另一个类。

有人使用元类实现面向切面编程和ORM？

#### 元类模型

##### 类是type的实例。

* 在3.x里，用户定义的类对象是type对象的实例，type对象自身也是一个类
* 在2.6里，新式类继承自object，object是type的子类。传统类是type的实例，但是不是从类中创建出来的。

```
>>> class C: pass           # 2.6中的传统类
...
>>> c = C()
>>> type(c)
<type 'instance'>
>>> type(C)
<type 'classobj'>
>>>
>>> class C(object): pass   # 2.6中的新式类
...
>>> c = C()
>>> type(c)
<class '__main__.C'>
>>> type(C)
<type 'type'>

>>> class C(object): pass   # 3.x中的类
...
>>> c = C()
>>> type(c)
<class '__main__.C'>
>>> type(C)
<class 'type'>
```

##### 元类是type的子类
元类是type的子类，类是type的实例，所以我们可以通过定制化元类来定制化类。

##### class声明协议

class声明协议: 在class语句执行完之后，在执行完所有内嵌代码后，会调用type对象来创建class对象。

```
class = type(classname, superclasses, attributedict)
```

type对象定义了一个\_\_call\_\_方法，该方法运行两个其他的方法。

```
type.__new__(typeclass, classname, superclasses, attributedict)
type.__init__(class, classname, superclasses, attributedict)
```
\_\_new\_\_方法创建和返回新的class对象。\_\_init\_\_初始化新创建的class对象。

举个例子:

```
class Spam(Eggs):
    data = 1
    def meth(self, arg):
        pass
        
Spam = type('Spam', (Eggs,), {'data': 1, 'meth': meth, '__module__': '__main__'})
```

#### 声明元类

```
class Spam(Eggs, metaclass=Meta): pass   # 3.0及后续版本

class Spam(object):                      # 2.6 版本
    __metaclass__ = Meta
    
Spam = Meta(classname, superclasses, attributedict)

#后续调用以下方法:
Meta.__new__(class, classname, superclasses, attributedict)
Meta.__init__(Meta, classname, superclasses, attributedict)
```



#### python中的高级功能

自省属性: \_\_class\_\_ \_\_dict\_\_

运算符重载方法: \_\_str\_\_ \_\_add\_\_等

属性拦截方法: \_\_getattr\_\_ \_\_setattr\_\_ \_\_getattribute\_\_

类property和类descriptor

函数和类装饰器

元类

