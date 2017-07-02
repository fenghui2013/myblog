---
title: 理论篇-python标准库之内建函数
date: 2017-07-01 19:13:31
tags:
    - python
---

函数 | 解释 | 特别说明
-----|----|-------
sorted | 排序 | python2 和 python3不同，需要functools.cmp\_to\_key



```
l = [2, 5, 1, 3, 6, 8, 4]


def mycmp(x, y):
    print(x, y)
    if x>y: return 1
    if x<y: return -1
    return 0

#sorted_l = sorted(l, cmp=mycmp)            # 2中可执行 3中不可以
sorted_l = sorted(l, key=functools.cmp_to_key(mycmp))  # 3中可执行

print(l)
print(sorted_l)
```