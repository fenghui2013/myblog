---
title: 理论篇-python之字符串
date: 2017-05-13 16:44:05
tags:
    - python
---

#### 编码与解码

ASCII标准首先被创建，该标准使用一个字节来表示一个字符，其中0-127表示普通字符，128-255没有使用，比如字符'a'的字节整数值是97。

随着计算机的发展，一些其他发达国家也开始使用了，比如欧洲的一些国家。但是他们发现一些字符ASCII标准里是没有的，于是他们拓展了ASCII标准，利用128-255来表示那些字符，发明了一个新的标准Latin-1标准。

计算机更普及了，世界上的一些发展中国家也开始使用计算机了。他们也发现他们的符号在ASCII中没有，并且也无法通过简单的扩展ASCII来容纳所有的符号。于是各个国家发明了自己的编码规则。

随着计算机的更加普及，国家之间通过计算机的交互也越来越多，由于各个国家之间的编码规则不统一，所以需要一套统一的编码规则。Unicode编码规则诞生了。Unicode字符串是一个宽字符的字符串，即一个文字可能由多个字节表示。

utf-8是Unicode编码规则的一种实现。0-127是单字节的，128-0x7ff是双字节的(每个字节的值的范围是128-255)，0x7ff以上是三个或四个字节(每个字节的值的范围是128-255)。这样既兼容了ASCII编码规则，也解决了字节的顺序问题。

ASCII、Latin-1、utf-8等其他多字节编码都是Unicode编码。

为了真正在计算机中存储这些文字，我们需要一套编码规则，将我们的文字编码为计算机可表示的字节序列以及当我们需要查看时将字节序列解码为文字。世界上不仅仅只有这两种编码规则，还有许多其他的编码规则，同一个符号，使用不同的编码规则将得到不同的字节序列。

**编码**: 依据编码规则，将文字转换成字节序列。**解码**: 依据编码规则，将字节序列转换成文字。


#### python中的字符串

```
# 2.x
str        # 8位的文本和二进制数据
unicode    # 宽字节的unicode文本

# 3.x
"xxx"
str        # unicode文本(单字节和宽字节)
b"xxx"
bytes      # 二进制数据(ASCII或者大于127的值进行转义后的十六进制值)
bytearray  # 可变的bytes类型的数组

str.encode()            # 编码类型可选，若不指定，则使用系统默认编码
bytes("xxx", encoding)  # 将str转换为bytes， 编码类型必选

bytes.decode()          # 编码类型可选，若不指定，则使用系统默认编码
str(b"xxx", encoding)   # 将bytes转换为str， 编码类型必选

\x                      # 十六进制转义符
\u \U                   # unicode转义符
"\xNN"  "\uNNNN" "\UNNNNNNNN"        # 字符串支持
len(s)                  # 针对\u字符串，返回的是字符数
```

3.x里，str本质是一个不可变的字符序列，bytes本质是一个不可变的8位整数序列，bytesarray本质是一个可变的8位整数序列。

在3.x里，打开文件的模式至关重要，决定了文件的处理方式和使用的python对象类型。

* 文本模式: 使用str对象，读写文件时，对内容进行编解码。
* 二进制模式: 使用bytes对象，读写文件时，不对内容做任何处理。

```
>>>b_s = b'spam'  # make a bytes object
>>>s_s = 'spam'   # make a str object 
```

```
>>>s = "XYZ"
>>>s.encode("ascii")       # values 0-127 in 1 byte(7 bits)
>>>s.encode("latin-1")     # values 0-255 in 1 byte(8 bits)
>>>s.encode("utf-8")       # values 0-127 in 1 byte, 128-2047 in 2 others 3 or 4
```

#### 源文件字符集编码声明

```
# -*- coding: latin-1 -*-

s = u"中国"
print(list(s))
----output----
[u'a', u'b', u'c', u'\xe4', u'\xb8', u'\xad', u'\xe5', u'\x9b', u'\xbd']


# -*- coding: utf-8 -*-

s = u"中国"
print(list(s))
----output----
[u'a', u'b', u'c', u'\u4e2d', u'\u56fd']
```

源文件字符集编码声明决定了源文件里的非ASCII的字符编码。

#### 系统默认编码
2.x的系统默认编码是ascii，3.x的系统默认编码是utf-8。系统默认编码最大的用途: 作为中间层。

```
s = u"abc中国"
s.decode("utf-8")  # 本质是s.encode(sysdefaultencoding).decode("utf-8")
```

#### 文件读写

```
# 3.x
open("filename", "w", encoding="utf-8").write("xxx") # 以utf-8编码写入文件
open("filename", "r", encoding="utf-8").read()  # 以utf-8编码读取文件

# 2.x
import codecs
codecs.open("filename", "w", encoding="utf-8").write("xxx")
codecs.open("filename", "r", encoding="utf-8").read()
```

对BOM(Byte Order Marker)的处理

```
```

#### 待看

```
Chapter 36. Other String Tool Changes in 3.0
```