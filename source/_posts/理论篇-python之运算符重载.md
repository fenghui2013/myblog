---
title: 理论篇-python之运算符重载
date: 2017-05-25 18:18:59
tags:
    - python
---

```
__repr__         # repr  适合开发人员阅读的信息
__str__          # print str  适合用户阅读的信息

本质上，__str__重载了__repr__，若没有__str__，则默认全部调用__repr__

__add__
__radd__
__iadd__

class Commuter:
    def __init__(self, val):
        self.val = val
    
    def __add__(self, other):
        print("__add__", self.val, other)
        return self.val + other
        
    def __radd__(self, other):
        print("__radd__", self.val, other)
        return other + self.val

    def __iadd__(self, other):
        print("__iadd__", self.val, other)
        self.val += other
        return self
        
x = Commuter(88)
y = Commuter(99)        
print(x+1)           # __add__
print(1+x)           # __radd__
print(x+y)           # __add__ __radd__
x += 1               # __iadd__


__call__             # 使一个实例可被调用

__lt__               # >
__le__               # >=
__gt__               # <
__ge__               # =<
__eq__               # ==
__ne__               # !=
__cmp__              # 返回一个整数值 大于0 小于0 或等于0 2.x中可用 3.x中已删除 优先使用以上六种运算符，若没有，再使用本运算符

class C:
    data = "spam"
    def __gt__(self, other):
        return self.data > other
    
    def __lt__(self, other):
        return self.data < other
        
    def __cmp__(self, other):
        return cmp(self.data, other)
        
x = C()
print(c > "ham")
print(c < "ham")

__bool__        
__len__          # 在boolean环境下，首先尝试__bool__，若没定义，则尝试__len__



__del__          # 析构函数
```