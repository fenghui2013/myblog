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
__getattribute__      # 拦截所有属性的访问(只能在新式类中使用)
__setattr__           # 拦截所有属性的赋值
__delattr__           # 拦截所有属性的删除

getattr(object, name[, default]) -> value  # object.name
```

防止循环调用的方法: 1. 使用属性字典 2. 调用父类的方法 3. 调用其他对象的方法

\_\_getattr\_\_和\_\_getattribute\_\_一般用在实现委托器模式的代码中。

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
    
    def __delattr__(self, name):
        print("__delattr__")
        del self.name
        
class Person(object):
    def __init__(self, name):
        self.name = name
    
    def __getattribute__(self, name):
        print("__getattribute__")
        return object.__getattribute__(self, name)
        
    def __setattr__(self, name, value):
        object.__setattr__(self, name, value)
        
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

### 进阶篇

#### \_\_getattr\_\_和\_\_getattribute\_\_需注意的点
正常的函数调用，会按照之前的规则拦截，但是对于重载函数的调用，拦截规则如下:

* 在3.x里，对于重载函数的隐式调用，\_\_getattr\_\_和\_\_getattribute\_\_不会拦截，显式调用会拦截
* 在2.6里，对于重载函数，无论显式调用还是隐式调用，若没有在类中定义，则\_\_getattr\_\_会拦截
* 在2.6里，对于重载函数的隐式调用，\_\_getattribute\_\_不会拦截，显式调用会拦截

2.6

类别 | 隐式调用 | 显式调用
----|---------|-------
\_\_getattr\_\_ | 若没定义则拦截 | 若没定义则拦截 
\_\_getattribute\_\_ | 不拦截| 拦截 

3.0

类别 | 隐式调用 | 显式调用
----|---------|-------
\_\_getattr\_\_ | 不拦截 | 若没定义则拦截 
\_\_getattribute\_\_ | 不拦截| 拦截 

#### property与descriptor的关系
既然property是descriptor的一种特例，那么它们之间是什么关系？

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

\_\_slots\_\_也是基于descriptor协议实现的。

#### 三者之间的关系

* \_\_getattr\_\_和\_\_getattribute\_\_一般用在实现委托器模式的代码中。一般用来管理内嵌对象的属性访问
* property和descriptor一般用来管理某个类的特定属性。