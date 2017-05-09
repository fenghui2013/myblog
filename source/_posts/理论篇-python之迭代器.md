---
title: 理论篇-python之迭代器
date: 2017-05-09 13:29:10
tags:
    - python
---

### 迭代器

迭代环境通过内置函数iter去尝试寻找\_\_iter\_\_方法来实现，而这种方法应该返回一个迭代器对象。如果找到了，python则会重复调用这个迭代器的next方法直到发生StopIteration异常。如果没有找到，python会改用\_\_getitem\_\_机制，通过偏移量重复索引，直到发生Index Error异常。