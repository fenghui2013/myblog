---
title: 实战篇-C之各种疑难杂症
date: 2017-08-11 09:57:42
tags:
    - C
---

>initializer element is not a compile-time constant

```
问题还原: 在定义全局变量时，若全局变量需要计算获取，则报此错误。
解决方案: 只声明全局变量，在函数内定义。
本质: todo
```