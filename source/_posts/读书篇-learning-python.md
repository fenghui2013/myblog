---
title: 读书篇-learning python
date: 2017-05-11 14:48:38
tags:
    - python
---

#### 32章 高级类主题

##### 扩展内置类型
讲解通过内嵌和子类的方式来扩展内置类型。

##### 新式类模型
引入新式类，之后重点讲解新式类与传统类的不同点。

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

    解决方案: 即实现__getattr__为了正常属性的访问，也实现那些需要访问的内建属性
    
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
