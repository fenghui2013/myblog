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
import       # 整体导入一个模块
from         # 将对象从被加载的模块中拷贝到当前模块中
reload       # reload只对python编写的源码有效且只对当前文件 (3.x里是imp.reload)
__dict__     # 模块的命名空间
__name__     # 若文件被当做主文件执行，则为"__main__", 若作为模块，则为文件名

python -O 生成优化的字节码文件
distutils  # 第三方软件
```

```
# small.py
x = 1
y = [1, 2]

from small import *

x = 42    # change local x only
y[0] = 42 # change shared mutalbe in-place
```

import导入时通常会运行\_\_import\_\_钩子函数来执行一些定制化的操作。本质是一个赋值语句。from的本质是建立一个共享对象的引用。

```
from module import name1, name2
is equal to 
import module
name1 = module.name1
name2 = module.name2
```

模块的命名必须遵守变量的命名规范，因为模块名称之后会变成一个变量。

不管使用import还是from，加载的对象只有一个。

一个函数不能访问另一个函数的变量，除非是闭包。一个模块不能访问另一个模块的变量，除非是显式的导入。

```
# a.py
X = 88
def f():
    global X
    X = 99

# b.py    
X = 11
import a
a.f()
print(X, a.X)  # 11, 99
```

reload是一个in-place的改变，会影响所有的import，但不会影响from。

```
# a.py
def test():
    print("......")

>>>from a import test
>>>test()              # output: .......
>>>import a
>>>reload(a)           # 对a做一些修改后重新加载
>>>test()              # 任然引用的是之前的对象
```

#### 自省
以下四个表达式效果一样

```
M.name
M.__dict__['name']
sys.modules['M'].name
getattr(M, 'name')
```

#### 从字符串中加载模块

```
modname = "string"
exec("import " + modname)  # 每次必须得编译import语句

string = __import__(modname)
```

#### 声明顺序

* 模块文件里的声明从上到下一个一个的执行，不允许提前引用
* 函数体内的代码直到函数运行时才执行，所以引用无限制

#### 题外话

C语言的#include仅仅是文本的替换