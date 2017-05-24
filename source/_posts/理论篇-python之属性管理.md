---
title: 理论篇-python之属性管理
date: 2017-05-23 16:38:28
tags:
    - python
---

python提供了两大类属性管理的方法，分别是:1. 基于运算符重载 2. 基于descriptor协议

#### 基于运算符重载的属性管理方法

```
__getattr__           # 拦截所有未定义属性的访问
__setattr__           # 拦截所有属性的赋值
__getattribute__      # 拦截所有属性的访问(只能在新式类中使用)
```

```
class Person:
    def __init__(self, name):
        self.name = name
        
    def __getattr__(self, name):
        print("__getattr__")
        return "undefined"
    
    def __setattr__(self, name, value):
        print("__setattr__")
        self.__dict__[name] = value   # important!!!
        
person = Person("xxx")
print(person.name)
person.age = 20
print(person.age)
print(person.sex)
```

#### 基于descriptor协议的属性管理方法
基于descriptor的属性管理方法必须在新式类中使用。

```
class Name(object):
    def __get__(self, instance, owner):
        print("__get__")
        return instance._name
        
    def __set__(self, instance, name):
        print("__set__")
        instance._name = name
        
    def __delete__(self):
        print("__delete__")
        del self._name
        
class Person(object):
    def __init__(self, name):
        self._name = name
        
    name = Name()
    
person = Person("xxx")
print(person.name)
person.name = "yyy"
print(person.name)
del person.name
person.age = 10
print(person.age)
```

#### 基于property的属性管理方法

property是descriptor协议的一种特例，基于property的属性管理方法必须在新式类中使用。

```
class Person(object):
    def __init__(self, name):
        self._name = name
        
    def getName(self):
        print("getName")
        return self._name
        
    def setName(self, name):
        print("setName")
        self._name = name
    
    def delName(self):
        print("delName")
        del self._name
        
    name = property(getName, setName, delName, None)
    
person = Person("xxx")
print(person.name)
person.name = "yyy"
print(person.name)
del person.name
person.age = 10
print(person.age)
```

### 进阶篇

#### property与descriptor的关系

```
class Property(object):
    def __init__(self, fget=None, fset=None, fdel=None, fdoc=None):
        self.fget = fget
        self.fset = fset
        self.fdel = fdel
        self.__doc__ = fdoc
        
    def __get__(self, instance, instanceType=None):
        if instance is None:
            return self
        if (self.fget is None):
            raise AttributeError("can't get attribute")
        return self.fget(instance)
        
    def __set__(self, instance, value):
        if (self.fset is None):
            raise AttributeError("can't set attribute")
        self.fset(instance, value)
        
    def __delete__(self, instance):
        if (self.fdel is None):
            raise AttributeError("can't delete attribute")
        self.fdel(instance)
        
    def setter(self, fset):
        self.fset = fset
        return self
    
    def deleter(self, fdel):
        self.fdel = fdel
        return self

class Person(object):
    def __init__(self, name):
        self._name = name
    
    def getName(self):
        print("getName")
        return self._name
    
    def setName(self, name):
        print("setName")
        self._name = name
    
    def delName(self):
        print("delName")
        del self._name
    
    name = Property(getName, setName, delName, None)
    
person = Person("xxx")
print(person.name)
person.name = "yyy"
print(person.name)
del person.name
person.age = 10
print(person.age)

class NewPerson(object):
    def __init__(self, name):
        self._name = name
    @Property
    def name(self):
        print("getName")
        return self._name
    @name.setter
    def name(self, name):
        print("setName")
        self._name = name
    @name.deleter    
    def name(self):
        print("delName")
        del self._name
        
person = NewPerson("xxx")
print(person.name)
person.name = "yyy"
print(person.name)
del person.name
person.age = 10
print(person.age)
```

使用装饰器的property

```
class Person(object):
    def __init__(self, name):
        self._name = name
    
    @property
    def name(self):
        print("getName")
        return self._name
    @name.setter
    def name(self, name):
        print("setName")
        self._name = name
    @name.deleter
    def name(self):
        print("delName")
        del self._name
        
person = Person("xxx")
print(person.name)
person.name = "yyy"
print(person.name)
del person.name
person.age = 10
print(person.age)
```

```
__getattr__       # 拦截所有未定义属性的访问
__setattr__       # 拦截所有属性的赋值

__getattribute__  # 新式类中拦截所有属性的访问(2.6之后和3.x)

attribute = property(fget, fset, fdel, doc)  # 返回一个property对象
property          # 新式类中路由特定的属性访问到预设的处理方法 properties

__get__
__set__           # routing specific attribute access to instances of classes with arbitrary get and set handler methods.
```

前两种方式是一般的，后两种是针对特定属性的。

属性协议允许我们路由一个特定的属性的get和set操作到我们提供的函数或方法上，使用我们能够插入在属性访问时自动运行的代码，拦截属性删除和为属性提供文档等。


```
class Descriptor:
    "docstring goes here"
    def __get__(self, instance, owner):
        pass
    def __set__(self, instance, value):
        pass
    def __delete__(self, instance):
        pass
        
没有__set__时，对实例的属性赋值也是可以的，所以如果想实现私有属性，则必须实现此方法。
```