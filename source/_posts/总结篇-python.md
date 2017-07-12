---
title: 总结篇-python
date: 2017-07-09 15:06:37
tags:
    - python
---

### 数据类型与数据结构

python支持的数据类型有Number, String, File

python支持的数据结构有list, dict, tuple, set

```
列表推导式
[x+1 for x in [1, 2]]
字典推导式
{x: x+1 for x in range(10)}
```

由于python是强类型语言，所以类型之间不行互相自动转换。

### 控制结构

python支持的控制结构: 

```
if <test> then:
    <statements>
elif <test>:
    <statements>
else:
    <statements>
    
三元表达式: A = "x" if True else "y"
A = True and "x" or "y"

while <test>:
    <statements>
else:   # 只有当循环正常离开时才会执行(即没有碰到break语句)
    <statements>    
    
    
for <target> in <object>:
    <statements>
else:   # 只有当循环正常离开时才会执行(即没有碰到break语句)
    <statements>
```

相关的内建函数: range zip map

迭代协议: \_\_iter\_\_ \_\_next\_\_

序列协议: \_\_getitem\_\_

### 函数

```
def <name>(arg1, arg2, arg3,... argN):
    <statements>
```

语法 | 解释
def func(name) | 常规参数 
def func(name=value) | 默认参数值
def func(\*name) | 匹配并收集(在元组中)所有包含位置的参数
def func(\*\*name) | 匹配并收集(在字典中)所有包含位置的参数

lambad表达式:

```
lambad arg1, arg2,... argN: expression using arguments
```


### 作用域

LEGB法则:

L: 本地作用域
E: 嵌套作用域
G: 全局作用域
B: 内置作用域

global语句的作用, nonlocal(py3.0之后)语句的作用

```
num = 1

def t1(name, count):
    def t2():
        global num
        nonlocal name, count
        name = "yyy"
        count += 1
        num += 1
        print(name, count, num)
    return t2

t1("xxx", 1)()
```

### 模块和包

import执行过程:

* 搜索

    搜索路径:
    
    * 程序主目录
    * PYTHONPATH目录
    * 标准库目录
    * 任何.pth文件的内容
* 编译
* 运行

重新导入模块: reload

包含\_\_init\_\_.py文件的目录即是包


```
sys.path # 所有的搜索路径
内建函数:__import__ 使用时必须显式导入内建库
模块属性: __name__
```
### 类

```
内建函数super的理解与使用
各种重载运算符
descriptor对属性的访问管理
类的继承与搜索方式
@classmethod
@staticmethod
多重继承以及实际中的应用
```

### 异常

环境管理协议:

1. 计算表达式，得到的对象为环境管理器，该管理器必须有\_\_enter\_\_和\_\_exit\_\_方法
2. 环境管理器的\_\_enter\_\_方法会被调用。若存在as子句，其返回值会赋给as子句中的变量，否则丢弃
3. 代码块中嵌套的代码将会执行
4. 发生异常或者代码块执行完毕后，都会调用\_\_exit\_\_(type, value, traceback)方法。若没有发生异常，则参数都为None。若发生异常，则为异常信息。

### 装饰器

实际开发中用的比较多，必须掌握。
### 元类

在写框架代码的时候用的较多。