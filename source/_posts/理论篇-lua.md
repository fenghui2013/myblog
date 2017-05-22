---
title: 理论篇-lua
date: 2017-05-21 20:30:28
tags:
    - lua
---

### language

> A chunk is simply a sequence of commands(or statements)

lua里面的**语句分隔符**没有实际意义，只是让人看上去比较清楚。

```
dofile("xxx.lua")       # 执行一个lua文件
```

lua里面的变量名可以除数字开头的字母、数字、下划线的任意组合，但是以下划线开头后跟大写字母的变量是lua语言保留的。lua是大小写敏感的。以下关键字也是lua语言保留的。

```
and break do else elseif end false goto for function if in
local nil not or repeat return then true until while
```

注释

```
--xxx            # 行注释
--[[xxx]]        # 块注释

# 小技巧
--[[             # 当取消该块注释时只需在前面加-
xxx
--]]
```

全局变量

lua里面的全局变量不需要显式声明。如果没有声明就使用，将得到nil。

当将一个变量赋值为nil时，意思是告诉lua编译器回收这个变量占用的内存。


解释器

```
#!/usr/bin/env lua
#!/usr/local/bin/lua    # 指定lua解释器

bogon:lua fenghui2013$ lua -h
lua: unrecognized option '-h'
usage: lua [options] [script [args]]
Available options are:
  -e stat  execute string 'stat'
  -i       enter interactive mode after executing 'script'
  -l name  require library 'name'
  -v       show version information
  -E       ignore environment variables
  --       stop handling options
  -        stop handling options and execute stdin
```

解释器在执行之前会寻找LUA\_INIT\_5\_2或LUA\_INIT全局变量，若内容是@filename，则执行该文件，否则执行全局变量的内容。