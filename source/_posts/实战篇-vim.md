---
title: 实战篇-vim
date: 2017-05-14 19:42:34
tags:
    - vim
---

#### 十六进制模式

```
:%! xxd     # 切换到十六进制方式
:%! xxd -r  # 切换到文本方式

hexdump -C -v xxx > xxx   # 导出文件的十六进制表示
```