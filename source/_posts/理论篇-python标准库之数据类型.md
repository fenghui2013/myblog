---
title: 理论篇-python标准库之数据类型
date: 2017-07-10 19:02:28
tags:
    - python
---


#### copy

类或方法 | 解释 | 特殊说明
-------|------|-------
copy.copy() | 浅拷贝 | 
copy.deepcopy() | 深拷贝 |
exception copy.eror | 

浅拷贝与深拷贝的区别:

浅拷贝只拷贝最外层的对象，而深拷贝会递归的拷贝所有对象。

```
__copy__
__deepcopy__
```

#### weakref

weakref允许创建对象的弱引用。

python使用自动垃圾回收机制，当一个对象的引用计数为0或只有弱引用时，执行垃圾回收。所以弱引用不影响对象的回收。

类或方法 | 解释 | 特殊说明
-------|------|-------
class weakref.ref(object[, callback]) | |
weakref.proxy(object[, callback]) | |
weakref.getweakrefcount(object) | |
weakref.getweakrefs(object) | |
class weakref.WeakKeyDictionary([dict]) | |
WeakKeyDictionary.keyrefs() | |
class weakref.WeakValueDictionary([dict]) | |
WeakValueDictionary.valuerefs() | |
class weakref.WeakSet([elements]) | |
class weakref.WeakMethod(method) | |
class weakref.finalize(obj, func, \*args, \*\*kwargs) | |
weakref.ReferenceType | |
weakref.ProxyType | |
weakref.CallableProxyType | |
weakref.ProxyTypes | |
exception weakref.ReferenceError | |

