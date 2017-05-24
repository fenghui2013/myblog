---
title: 理论篇-python之遍历
date: 2017-05-09 13:29:10
tags:
    - python
---

python为我们提供了两种遍历对象的协议: 1. 索引协议 2. 迭代协议

索引协议:

迭代协议:

```
for temp in xxx:
    do something
```
当我们使用for循环遍历某一个对象时，python的处理过程如下:

* 寻找迭代协议的实现
* 若没有找到迭代协议的实现，则寻找索引协议的实现
* 若没有找到索引协议的实现，则报错

#### 迭代协议的实现

当一个对象实现了\_\_iter\_\_和next方法，我们就说这个对象实现了迭代协议。

```
class OperatorOverloadTest:
    def __init__(self, val_l):
        self.val_l = val_l
        
    def __iter__(self):
        self._index = 0
        return self
        
    def next(self):
        if self._index == len(self.val_l):
            raise StopIteration
        temp = self.val_l[self._index]
        self._index += 1
        return temp
        
l = [temp for temp in "abcdefghijklmnopqrstuvwxyz"]
oot = OperatorOverloadTest(l)
for temp in oot:
    print temp
```

#### 索引协议的实现

当一个对象实现了\_\_getitem\_\_和\_\_settiem\_\_方法，我们就说这个对象实现了索引协议。

```
class OperatorOverloadTest:
    def __init__(self, val_l):
        self.val_l = val_l
        
    def __getitem__(self, index):
        return self.val_l[index]
        
    def __setitem__(self, index, value):
        self.val_l[index] = value
        
l = [temp for temp in "abcdefghijklmnopqrstuvwxyz"]
oot = OperatorOverloadTest(l)
for temp in oot:
    print temp
```

#### 两个协议都实现了

当我们两个协议都实现了的情况下，python又是怎么处理的呢？

```
class OperatorOverloadTest:
    def __init__(self, val_l):
        self.val_l = val_l
        
    def __iter__(self):
        print("__iter__")
        self._index = 0
        return self
        
    def next(self):
        if self._index == len(self.val_l):
            raise StopIteration
        temp = self.val_l[self._index]
        self._index += 1
        return temp
        
    def __getitem__(self, index):
        print("__getitem__")
        return self.val_l[index]
        
    def __setitem__(self, index, value):
        self.val_l[index] = value
        
l = [temp for temp in "abcdefghijklmnopqrstuvwxyz"]
oot = OperatorOverloadTest(l)
for temp in oot:
    print temp
```

运行上面的测试用例可以看到，python实际使用的是迭代协议的实现。

### 进阶篇

#### 迭代协议实现的问题

当我们对实现迭代协议的对象进行多次遍历时，会出现什么情况呢？结果是只有第一次遍历有结果，其他的遍历都没有任何结果。该问题的解决方案是\_\_iter\_\_返回一个实现迭代协议的对象。

```
class OperatorOverloadTest:
    def __init__(self, val_l):
        self.val_l = val_l
        
    def __iter__(self):
        return OperatorOverloadTest.MyIterator(self.val_l)
        
    class MyIterator:
        def __init__(self, wrapped):
            self.wrapped = wrapped
            self._index = 0
            
        def next(self):
            if self._index == len(self.wrapped):
                raise StopIteration
            temp = self.wrapped[self._index]
            self._index += 1
            return temp
        
l = [temp for temp in "abcdefghijklmnopqrstuvwxyz"]
oot = OperatorOverloadTest(l)
for temp in oot:
    print temp,
print
    
for temp in oot:
    print temp,
```

### 扩展篇

对于in操作，python提供了三种方式: 1. \_\_contains\_\_ 2. 迭代协议 3. 索引协议

当我们使用in运算符时，python的处理过程如下:

* 寻找\_\_contains\_\_的实现
* 若没有找到\_\_contains\_\_的实现，则寻找迭代协议的实现
* 若没有找到迭代协议的实现，则寻找索引协议的实现
* 若没有找到索引协议的实现，则报错