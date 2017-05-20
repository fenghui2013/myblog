---
title: 源码篇-innodb之数据页结构解析
date: 2017-05-19 11:22:53
tags:
    - mysql
---

![index_page_overview](/img/index_page_overview.png)

```
数据页开始的地方:16KB*3=0xc000

file header(38):
47 71 e9 33               # 该页的checksum值
00 00 00 03               # 该页的偏移量，从0开始
ff ff ff ff               # 前一页，因为只有当前页所有为0xffffffff
ff ff ff ff               # 后一页，因为只有当前页所以为0xffffffff
00 00 00 00 00 01 d7 42   # 该页的LSN
45 bf                     # 页类型，该页为数据页
00 00 00 00 00 00 00 00   #
00 00 00 05               # 表空间的space id

index header(36):
00 02                     # page directory 占用2个槽，每个槽占用2个字节
01 9c                     # 空闲空间开始位置的偏移量 0xc000+0x019c=0xc19c
80 09                     # 初始值为0x8002，0x8009-0x8002=0x0007 代表共有7条记录
00 00                     # 删除的记录数
00 00                     # 删除记录的字节数总和
01 79                     # 最后插入位置的偏移量
00 02                     # 插入方向
00 06                     # 一个方向连续插入的记录数
00 07                     # 该页的行记录数
00 00 00 00 00 00 00 00
00 00                     # 该页在B+树中的层数
00 00 00 00 00 00  00 17  # 索引id

FSEG header(20):
00 00 00 05 00 00 00 02 00 f2
00 00 00 05 00 00 00 02 00 32

system records:
0xc05e~0xc077
01 00 02 00 1e            # record header
69 6e 66 69 6d 75 6d 00   # infimum   0xc063+0x001e=0xc081 第一条记录开始的位置
08 00 0b 00 00            # record header
73 75 70 72 65 6d 75 6d   # supremum

user records:

page directory:(逆序存放)
00 70 00 63
0x0063是第一条记录的相对位置
0x0070是最后一条记录的相对位置


file trailer(8):
35 bb de bd               # checksum值，该值通过checksum函数和file header部分的checksum值进行比较
00 01 d7 42               # 注意到该值与file header页中的后lsn后四位相等
```