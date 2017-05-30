---
title: 理论篇-python之运算符重载
date: 2017-05-25 18:18:59
tags:
    - python
---

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