---
title: 实战篇-vim
date: 2017-05-14 19:42:34
tags:
    - vim
---

```
:%! xxd     # 切换到十六进制方式
:%! xxd -r  # 切换到文本方式

hexdump -C -v xxx > xxx   # 导出文件的十六进制表示

start, end s/old/new/g    # 替换从start到end之前的行
%s/old/new/g              # 全局替换
```