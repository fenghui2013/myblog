---
title: java编程之各种坑
date: 2017-04-17 20:38:29
tags:
    - java
---

### 比较大小
在java的世界里，会对[-128, 127]之间的Integer做一个缓存。而==比较的引用。所以会出现如下现象:

```
Integer a_I = 100;
Integer b_I = 100;
Integer c_I = 200;
Integer d_I = 200;
int a_i = 100, b_i = 100, c_i = 200, d_i = 200;
System.out.println(a_I == b_I);       # true
System.out.println(c_I == d_I);       # false
System.out.println(c_I.equals(d_I));  # true
System.out.println(c_I >= d_I);       # true
System.out.println(a_i == b_i);       # true
System.out.println(c_i == d_i);       # true
System.out.println(c_i >= d_i);       # true
```
解决办法: 尽量使用equals()方法。