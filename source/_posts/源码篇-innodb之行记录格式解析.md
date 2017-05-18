---
title: 源码篇-innodb之行记录格式解析
date: 2017-05-18 17:22:12
tags:
    - mysql
---

### 故事背景
最近在学mysql，看的是《Mysql技术内幕: InnoDB存储引擎》，在读到行记录格式时，发现一个让自己无法理解的事情。于是就揪出了innodb的源码仔细研究一番，最后发现书中的语言确实会将人带入一种认识的误区，也可能是个人理解能力有问题，不说这个了，我们直接说问题。

### 测试用例

```
create table mytest (
    t1 varchar(10),
    t2 varchar(10),
    t3 char(10),
    t4 varchar(10)
) engine=innodb charset=latin1 row_format=compact;

insert into mytest values("a", "bb", "bb", "ccc");
insert into mytest values(NULL, "bb", "bb", "ccc");
insert into mytest values("a", "bb", "bb", "ccc");
insert into mytest values(NULL, NULL, "bb", "ccc");
insert into mytest values("a", "bb", "bb", "ccc");
insert into mytest values(NULL, "bb", NULL, NULL);
insert into mytest values("a", "bb", "bb", "ccc");
```

物理文件中的内容如下:

```
0000bff0  00 00 00 00 00 00 00 00  95 17 2a 17 00 01 d3 70  |..........*....p|
0000c000  47 71 e9 33 00 00 00 03  ff ff ff ff ff ff ff ff  |Gq.3............|
0000c010  00 00 00 00 00 01 d7 42  45 bf 00 00 00 00 00 00  |.......BE.......|
0000c020  00 00 00 00 00 05 00 02  01 9c 80 09 00 00 00 00  |................|
0000c030  01 79 00 02 00 06 00 07  00 00 00 00 00 00 00 00  |.y..............|
0000c040  00 00 00 00 00 00 00 00  00 17 00 00 00 05 00 00  |................|
0000c050  00 02 00 f2 00 00 00 05  00 00 00 02 00 32 01 00  |.............2..|
0000c060  02 00 1e 69 6e 66 69 6d  75 6d 00 08 00 0b 00 00  |...infimum......|
0000c070  73 75 70 72 65 6d 75 6d  03 02 01 00 00 00 10 00  |supremum........|
0000c080  2b 00 00 00 00 08 05 00  00 00 00 11 0c 80 00 00  |+...............|
0000c090  00 2d 01 10 61 62 62 62  62 20 20 20 20 20 20 20  |.-..abbbb       |
0000c0a0  20 63 63 63 03 02 01 00  00 18 00 2b 00 00 00 00  | ccc.......+....|
0000c0b0  08 06 00 00 00 00 11 0d  80 00 00 00 2d 01 10 62  |............-..b|
0000c0c0  62 62 62 20 20 20 20 20  20 20 20 63 63 63 03 02  |bbb        ccc..|
0000c0d0  01 00 00 00 20 00 2a 00  00 00 00 08 07 00 00 00  |.... .*.........|
0000c0e0  00 11 0e 80 00 00 00 2d  01 10 61 62 62 62 62 20  |.......-..abbbb |
0000c0f0  20 20 20 20 20 20 20 63  63 63 03 03 00 00 28 00  |       ccc....(.|
0000c100  29 00 00 00 00 08 08 00  00 00 00 11 0f 80 00 00  |)...............|
0000c110  00 2d 01 10 62 62 20 20  20 20 20 20 20 20 63 63  |.-..bb        cc|
0000c120  63 03 02 01 00 00 00 30  00 29 00 00 00 00 08 09  |c......0.)......|
0000c130  00 00 00 00 11 10 80 00  00 00 2d 01 10 61 62 62  |..........-..abb|
0000c140  62 62 20 20 20 20 20 20  20 20 63 63 63 0b 00 00  |bb        ccc...|
0000c150  38 00 26 00 00 00 00 08  0a 00 00 00 00 11 11 80  |8.&.............|
0000c160  00 00 00 2d 01 10 62 62  20 20 20 20 20 20 20 20  |...-..bb        |
0000c170  03 02 01 00 00 00 40 fe  f7 00 00 00 00 08 0b 00  |......@.........|
0000c180  00 00 00 11 12 80 00 00  00 2d 01 10 61 62 62 62  |.........-..abbb|
0000c190  62 20 20 20 20 20 20 20  20 63 63 63 00 00 00 00  |b        ccc....|
```

按照书中所说，我们按照协议格式解析第一条及第二条记录如下:

```
第一条记录从0xc078开始: "a", "bb", "bb", "ccc"
03 02 01                       # 变长字段长度列表，逆序，分别代表ccc bb a的实际长度为3 2 1
00                             # NULL标志位
00 00 10 00 2b                 # 头信息，固定长度 5字节 0x002b代表下一个记录的偏移量
00 00 00 00 08 05              # rowId
00 00 00 00 11 0c              # transactionId
80 00 00 00 2d 01 10           # rollback pointer
61                             # 'a'
62 62                          # 'bb'
62 62 20 20 20 20 20 20 20 20  # 'bb'  固定长度其后用20补充
63 63 63                       # 'ccc'

第二条记录从0xc0a4开始: NULL, "bb", "bb", "ccc"
03 02                          # 变长字段长度列表，逆序，分别代表ccc bb a的实际长度为3 2 1
01                             # NULL标志位, 0000 0001，表示第一个字段为NULL
00 00 18 00 2b                 # 头信息，固定长度 5字节 0x002b代表下一个记录的偏移量
00 00 00 00 08 06              # rowId
00 00 00 00 11 0d              # transactionId
80 00 00 00 2d 01 10           # rollback pointer
62 62                          # 'bb'
62 62 20 20 20 20 20 20 20 20  # 'bb'  固定长度其后用20补充
63 63 63                       # 'ccc'
```
但是，问题来了，0xc078+0x002b=0xc0a3，与实际的开始地址0xc0a4不符，怎么回事呢？通过看代码，原来每行记录的开始地址是从第一列数据开始，通过下面的代码依次获得后面的记录。

```
#为了简单，将许多无关的代码删除掉了
#define UNIV_PAGE_SIZE      0x4000  # 16KB
#define REC_NEXT          2

# 第一条记录的开始地址是0xc081，返回值0xc0ac
page_rec_get_next(rec)
{
    return((rec_t*) page_rec_get_next_low(rec, page_rec_is_comp(rec)));
}
page_rec_get_next_low(rec)
{
    page = page_align(rec);  # page: 0xc000
    offs = rec_get_next_offs(rec);  # offs: 0xac
    return(page + offs);
}
page_align(rec)
{
    return((page_t*) ut_align_down(ptr, UNIV_PAGE_SIZE));
}
ut_align_down(rec)
{
    return((void*)((((ulint) ptr)) & ~(align_no - 1)));
}


rec_get_next_offs(rec)  # return: 0x00ac
{
    field_value = mach_read_from_2(rec - REC_NEXT);  # field_value: 0x002b
    return(ut_align_offset(rec + field_value, UNIV_PAGE_SIZE));
}
ut_align_offset(ptr, align_no)
{
    return(((ulint) ptr) & (align_no - 1)); # ptr: 0xc0ac align_no: 0x4000 return:0x00ac
}
mach_read_from_2(b)  # b: 0xc07f b[0]:00 b[1]: 2b return: 0x002b
{
    return(((ulint)(b[0]) << 8) | (ulint)(b[1]));
}
```

通过上面的分析，原来第一条记录的开始地址是0xc081，第二条记录的开始地址是0xc0ac。实际的页内记录格式如下图所示:

![b+_simplified_leaf_page](/img/b+_simplified_leaf_page.png)

实际是一个单链表。