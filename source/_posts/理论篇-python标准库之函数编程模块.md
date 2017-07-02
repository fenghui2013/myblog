---
title: 理论篇-python标准库之函数编程模块
date: 2017-07-01 18:50:14
tags:
    - python
---

#### itertools

#### functools

functools模块为了更高级的函数: 操作或者返回其他函数的函数。

方法 | 作用 | 特别说明
-----|------|-------
functools.cmp\_to\_key(func) | 将一个comparison function 转换到 key function | py2到py3的sorted函数中使用
@functools.lru\_cache(maxsize=128, typed=False) | 根据入参缓存函数的执行结果，以提高程序的效率 |
@functools.total\_ordering | 自动填充剩余的比较方法 | The class must define one of \_\_lt\_\_(), \_\_le\_\_(), \_\_gt\_\_(), or \_\_ge\_\_(). In addition, the class should supply an \_\_eq\_\_() method. 
functools.partial(func, \*args, \*\*kwargs) | 给函数添加默认参数 | 
class functools.partialmethod(func, \*args, \*\*keywords) | | 
functools.reduce(function, iterable[, initializer]) | 与py2中的内建函数reduce功能一样 在py3中删除了reduce内建函数 | 
@functools.singledispatch(default) | 使函数具有针对不同类型参数做不同处理的能力 | 非常有用
functools.update_wrapper(wrapper, wrapped, assigned=WRAPPER\_ASSIGNMENTS, updated=WRAPPER\_UPDATES) | | 
@functools.wraps(wrapped, assigned=WRAPPER\_ASSIGNMENTS, updated=WRAPPER\_UPDATES) | 这是update_wrapper函数的装饰器版本 更新一个包裹函数 让其更像被包裹的函数| 非常有用 特别是写装饰器的时候 

```
import functools

-------- cmp_to_key --------
l = [2, 5, 1, 3, 6, 8, 4]

def mycmp(x, y):
    print(x, y)
    if x>y: return 1
    if x<y: return -1
    return 0

#sorted_l = sorted(l, cmp=mycmp)
sorted_l = sorted(l, key=functools.cmp_to_key(mycmp))

print(l)
print(sorted_l)


d = [("c", 3), ("a", 1), ("e", 6)]


sorted_d = sorted(d, key=lambda x: x[1], reverse=True)

print(sorted_d)

-------- lru_cache --------

@functools.lru_cache(maxsize=32)
def hehe(num):
    print(num)
    return num+10

l = [1, 3, 1, 3, 1, 3]
print(l)

for temp in l:
    hehe(temp)

print(hehe.cache_info())

-------- partial --------

basetwo = functools.partial(int, base=2)
print(basetwo('1111'))

-------- singledispatch --------

@functools.singledispatch
def fun(arg, verbose=True):
    if verbose:
        print("hello, ", end="")
    print(arg)

@fun.register(list)
def _(arg, verbose=True):
    if verbose:
        print("hi, ", end="")
    for temp in arg:
        print(temp, end=" ")
    print()

fun(1)
fun("world")
fun([1, 2, 3])
```

#### operator