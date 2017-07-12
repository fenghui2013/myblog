---
title: 理论篇-python之异常
date: 2017-07-10 10:06:54
tags:
    - python
---

```
try/except/else/finally     # 捕获异常并恢复 没发生异常时执行else 无论是否发生异常都执行finally
raise               # 手动在代码中触发异常
assert              # 有条件的在程序中触发异常
```


内置异常分类

内置异常 | 解释 | 特殊说明 
--------|-----|----------
BaseException | 异常的顶级根类 | 
Exception | 与应用相关的异常顶级根超类 | 用户定义的异常应该继承此类
ArithmeticError | 所有数值错误的超类 | Exception的子类
OverflowError | 识别特定数值错误的子类 | 