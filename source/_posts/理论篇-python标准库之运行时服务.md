---
title: 理论篇-python标准库之运行时服务
date: 2017-07-02 14:08:40
tags:
    - python
---

#### sys

#### sysconfig

#### builtins

#### \_\_main\_\_

#### warnings

#### contextlib

方法 | 用法 | 特殊说明
----|------|-------
@contextlib.contextmanager | 定义上下文管理的工厂方法 | 
contextlib.closing(thing) | | 
contextlib.suppress(*exceptions) | 排除某些异常 |
contextlib.redirect_stdout(new_target) | 重定向标准输出 |
contextlib.redirect_stderr(new_target) | 重定向错误输出 |  

```
import contextlib

@contextlib.contextmanager
def tag(name):
    print("<%s>" % name)
    yield
    print("</%s>" % name)

with tag("h1"):
    print("foo")
    
    
tornado中使用该库管理回调函数执行中产生的异常
```

#### abc

#### atexit

#### traceback

#### \_\_future\_\_

#### gc

#### inspect

#### site

#### fpectl