---
title: 实战篇-python之mixin模式
date: 2017-05-11 17:46:14
tags:
    - python
---

实现功能组合的方式有多种，比如继承、组合等，但是如果代码结构比较复杂，相应的继承结构也会比较混乱。Mixin模式是一种简单有效的功能组合方式。实现的方法是: 每个类实现单一的功能，然后利用多继承机制，将单一功能组合起来，实现一个新类。


先看下代码

```
class AMixin:
    def getA(): return "a"
    
class BMixin:
    def getB(): return "b"
    
class C(AMixin, BMixin): pass

c = C()

c.getA()
c.getB()
```

mixin模式好处是可以简化继承树，使结构更加清楚。