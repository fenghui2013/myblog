---
title: 理论篇-python标准库之内建函数
date: 2017-07-01 19:13:31
tags:
    - python
---

函数 | 解释 | 特别说明
-----|----|-------
abs(x) | 返回一个数的绝对值 |
all(iterable) | 如果所有元素都为真或者迭代器是空的则返回true 否则返回false |
any(iterable) | 如果任意一个元素为真则返回true 否则返回false | 
enumerate(iterable, start=0) | 返回一个包含从start开始计数的元组数组 |
class dict(\*\*kwarg) | |
class dict(mapping, \*\*kwarg) | |
class dict(iterable, \*\*kwarg) | 返回一个字典 |
filter(function, iterable) | 返回一个迭代器 过滤元素 |
getattr(object, name[, default]) | 获得对象的属性值 | 
hasattr(object, name) | 判断对象是否有该属性 |
hex(x) | 转换一个整数值到一个十六进制值 以"0x"为前缀 |
int(x=0) | |
int(x=0, base=10) | 将一个数字或者字符串转换为整数 base是进制 |
iter(object[, sentinel]) | 返回一个迭代对象， object要么支持迭代协议或序列协议 要么有第二个参数且object是可调用的 | 
len(s) | 返回一个对象的长度 |
map(function, iterable, ...) | 返回一个迭代器 将function应用到传入的迭代器中的每一项 | 
oct(x) | 将一个数字转换为八进制字符串 |
class list([iterable]) | 将一个可迭代对象转换为可变的列表 |  
range(stop) | | 
range(start, stop[, step]) | 返回一个不可变序列 | 
setattr(object, name, value) | 给某个对象设置属性值 | 
sorted | 排序 | python2 和 python3不同，需要functools.cmp\_to\_key
super | 返回一个代理对象，委托方法调用到父类或者兄弟类 |
zip | 聚合n个可迭代的对象为一个可迭代对象 | zip(['A', 'B'], [1, 2], ['a', 'b']) => (('A', 1, 'a'), ('B', 2, 'b'))


super的两种主要用法:

* 在单继承的类结构里，super被用来指向父类，而不用显式声明。这和其他语言中的super功能类似
* 在多继承的类结构里，这是python独一无二的，在其他编译型语言或者单继承的语言里不可见。
* 无参的super()调用只能在类中使用，其它方式的调用没有此限制

zip的用途:

* 用于列表的并行遍历

```
-------- enumerate --------
>>>seasons = ['Spring', 'Summer', 'Fall', 'Winter']
>>>list(enumerate(seasons))
[(0, 'Spring'), (1, 'Summer'), (2, 'Fall'), (3, 'Winter')]

-------- sorted --------
l = [2, 5, 1, 3, 6, 8, 4]

def mycmp(x, y):
    print(x, y)
    if x>y: return 1
    if x<y: return -1
    return 0

#sorted_l = sorted(l, cmp=mycmp)            # 2中可执行 3中不可以
sorted_l = sorted(l, key=functools.cmp_to_key(mycmp))  # 3中可执行

print(l)
print(sorted_l)

-------- zip --------
list(zip('ABCD', '1234', 'abcd'))

-------- super --------
class A:
    def test(self):
        print("A")

class B:
    def test(self):
        print("B")

class C:
    def test(self):
        print("C")

class D(A, B, C):
    def test(self):
        super(B, self).test()
        print("D")


d = D()
d.test()
```