---
title: 理论篇-python之模块
date: 2017-05-11 21:51:34
tags:
    - python
---

模块是一种代码组织的单元，是一种命名空间，本质是一个字典。

import的工作原理:

1. 发现模块文件
    * 程序的home目录(即可执行文件所在的目录)
    * PYTHONPATH目录(如果设置了的话，是一个列表)
    * 标准库目录
    * 任何.pth文件的内容(如果有的话，位置/usr/local/lib/python3.0/site-packages or /usr/local/lib/site-python)
2. 编译到字节码(需要的时候)
    
    通过比较.py文件和.pyc文件的时间戳来判断是否需要重新编译。编译只有在导入的时候发生，.pyc是编译产生的字节码文件。
3. 运行字节码来构建对象
    
    文件里的所有语句从上到下执行，赋值语句将生成模块的属性。

只有当**第一次**import一个模块的时候才会执行以上步骤。随后的import仅仅是获取已经在内存中的对象。被导入的模块被存在sys.modules表里。

"import b"该语句执行的时候将会搜索如下文件或目录:

* 源文件b.py
* 字节码文件b.pyc
* 目录b
* C或C++编写的被编译的扩展模块，当导入的时候通常被动态链接(例如b.so或者 b.dll)
* 一个用C编写的被编译的内置模块，静态链接到python
* 一个zip文件组件，当被导入时自动解压
* An in-memory image, for frozen executables
* A java class, in the Jython version of python
* A .net component, in the IronPython version of python


```
sys.modules  # 已导入的所有的模块
sys.path     # 所有的搜索目录，包括以上四个搜索路径的列表
import
from
imp.reload

python -O 生成优化的字节码文件
distutils  # 第三方软件
```

import导入时通常会运行__import__钩子函数来执行一些定制化的操作。


#### 题外话

C语言的#include仅仅是文本的替换