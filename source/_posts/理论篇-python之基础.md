---
title: 理论篇-python编程之基础
date: 2017-04-20 20:56:32
tags:
    - python
---

在python的世界中，万物皆对象。

* 可作用于多种类型的通用型操作都是以内置函数或表达式的形式出现的，类型特定的操作是以方法调用的形式出现的

### 数据类型

类型  | 例子
-----|-----
number | 1234, 3.14
string | 'xxx'
list   | [1, [2, 3], 4]
dict   | {"xxx":[1, 2], "a": "b"}
tuple  | (1, 'xxx', 4)
file   | f = open('xxx', 'r')
set    | set('abc')
other core types   | boolean type None
program unit types | function module class

#### 字符串

* 以字符序列的形式存储的
* 支持负索引
* 不可变
* 字符串方法
* 格式化操作

```
a = "aaa"
b = "bbb"
a + b > "aaabbb"
a * 2 > "aaaaaa"

"%s %s" % ("hello", "world")
"{0} {1}".format("hello", "world")
```