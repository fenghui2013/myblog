---
title: 理论篇-python之命名空间
date: 2017-05-08 20:47:12
tags:
    - python
---

global与nonlocal

* nonlocal是3.0以后加入的
* global是全局的变量
* nonlocal是非本地的最近的一个作用域内的变量(待验证)

```
# 2.x
x = 1

def f():
    x = 10
    def g():
        global x
        x += 1
        print(x)
    return g

f()()

# 3.x
x = 1

def f():
    x = 10
    def g():
        nonlocal x
        x += 1
        print(x)
    return g

f()()
```

#### 个人感悟

* 命名空间本质是字典
* 实例有实例的命名空间，类有类的命名空间