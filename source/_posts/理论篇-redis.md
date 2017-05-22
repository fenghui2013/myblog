---
title: 理论篇-redis
date: 2017-05-04 16:20:50
tags:
    - redis
---

### 数据结构与对象

redis中一切皆对象，共包含5种对象，分别为字符串对象(string object)、列表对象(list object)、哈希对象(hash object)、集合对象(set object)、有序集合对象(sorted set object)。

#### 数据结构

##### 简单动态字符串

```
struct sdshdr {
    int len;      # 字符串长度
    int free;     # 未使用空间长度
    char buf[];   # 字节数组
}
```
与C字符串的比较:

* 通过len字段，获取字符串长度的时间复杂度为O(1)
* 通过len字段，杜绝了缓冲区溢出问题
* 通过预分配策略和惰性空间释放策略避免了频繁的内存重分配
* 二进制安全
* 通过保留最后一个字符为空字符，可以复用C的字符串库函数，但是前提是字符串中不包含空字符，否则处理出错

##### 双向列表

```
typedef struct listNode {
    struct listNode *prev;               # 前一个节点
    struct listNode *next;               # 后一个节点
    void *value;                         # 节点值
} listNode;

typedef struct list {
    listNode *head;                      # 表头节点
    listNode *tail;                      # 表尾节点
    unsigned long len;                   # 节点数量
    void *(*dup)(void *ptr);             # 节点值复制函数
    void *(*free)(void *ptr);            # 节点值释放函数
    int (*match)(void *ptr, void *key);  # 节点值对比函数
} list;
```

通过使用指定value的值为void*和dup、free、match可以实现多态链表。

##### 哈希表

```
哈希表
typedef struct dictht {
    dictEntry **table;      # 哈希表数组
    unsigned long size;     # 哈希表大小
    unsigned long sizemask; # 哈希表大小掩码，用于计算索引值，总是等于size-1
    unsigned long used;     # 键值对数量
} dictht;

load_factor = ht[0].used/ht[0].size;   # 负载因子

哈希表节点
typedef struct dictEntry {
    void *key;              # 键
    union {
        void *val;
        uint64_t u64;
        int64_t s64;
    } v;                    # 值
    struct dictEntry *next; # 下一个节点，用于解决冲突
} dictEntry;

字典
typedef struct dict {
    dictType *type;         # 类型特定函数，为实现多态字典
    void *privdata;         # 保存传给特定函数的可选参数
    dictht ht[2];           # 哈希表
    int rehashidx;          # 当rehash不在进行时，值为-1，否则为哈希表数组的索引
} dict;
ht属性包含两个哈希表，一般使用第一个，第二个只在rehash时才使用。

typedef struct dictType {
    unsigned int (*hashFunction)(const void *key);     # 哈希函数
    void *(*keyDup)(void *privdata, const void *key);  # 复制键的函数
    void *(*valDup)(void *privdata, const void *obj);  # 复制值的函数
    int *(*keyCompare)(void *privdata, const void *key1, const void *key2);                                                # 比较键的函数
    void *(*keyDestructor)(void *privdata, void *key); # 销毁键的函数
    void *(*valDestructor)(void *privdata, void *obj); # 销毁值得函数
} dictType;
```

MurmurHash算法

##### 跳跃表
实现有序集合的底层数据结构之一是跳跃表。当有序集合包含的元素数量比较多，又或者有序结合中元素的成员是比较长的字符串时，redis就会使用跳跃表作为有序集合键的底层实现。

跳跃表支持平均O(lgN)，最坏O(N)的时间复杂度。大部分情况下，跳跃表的性能可以和平衡树相媲美，又因为跳跃表的实现比平衡树简单，所以很多程序使用跳跃表来代替平衡树。

```
typedef struct zskiplistNode {
    struct zskiplistLevel {
        struct zskiplistNode *forward;  # 前进指针
        unsigned int span;              # 跨度
    } level[];                          # 层
    struct zskiplistNode *backward;     # 后退指针
    double score;                       # 分值
    robj *obj;                          # 成员对象
} zskiplistNode;

typedef struct zskiplist {
    struct zskiplistNode *header, *tail;   # 头尾节点
    unsigned long length;                  # 节点数量
    int level;                             # 层数最大的节点的层数
} zskiplist;
```

根据幂次定律生成层数。

##### 整数集合
实现集合的底层数据结构之一是整数集合。当一个集合只包含整数元素，并且这个集合的元素数量不多时，redis就会使用整数集合作为集合的底层实现。

```
typedef struct intset {
    uint32_t encoding;    # 编码方式: int16_t int32_t int64_t
    uint32_t length;      # 元素数量
    int8_t contents[];    # 保存元素的数组
} intset;
```

**升级**:每当添加一个新元素，并且新元素比所有现有元素的类型都要长时整数集合需要先进行升级，然后才能将新元素添加到整数集合里面。

**只有升级没有降级**

##### 压缩列表

压缩列表是列表和哈希的底层实现之一。当一个列表键只包含少量列表项，并且每个列表项要么是小整数要么是长度比较短的字符串，那么redis就会使用压缩列表作为列表的底层实现。当一个字典，只包含少量键值对，并且每个键值对的键和值要么是小整数要么是长度比较短的字符串，那么redis就会使用压缩列表作为字典的底层实现。

```
# ziplist
zlbytes|zltail|zllen|entry1|entry2|...|entryN|zlend

# ziplistEntry
previous_entry_length|encoding|content
```

* 压缩列表是一种为节约内存而开发的顺序型数据结构
* 压缩列表被用作列表和字典的底层实现之一
* 压缩列表可以包含多个节点，每个节点可以保存一个字节数组或整数值
* 添加新节点到压缩列表或从压缩列表中删除节点，可能会引发连锁更新操作，但这种操作出现的几率并不高

#### 对象
redis有一个对象系统，该系统包括字符串对象、列表对象、哈希对象、集合对象和有序集合对象这五种类型的对象。每种对象至少用到了一种我们之前介绍的数据结构。

redis执行命令前，根据对象的类型来判断一个对象是否可以执行给定的命令。redis可以在不同的场景下，为同样的对象选择不同的数据结构，从而达到最高的使用效率。

redis实现了基于引用计数技术的内存回收机制，且通过引用计数技术实现了对象共享机制。

对象还带有时间信息，该信息用于计算键的空转时长，当服务器启用maxmemory时，空转时长长的那些键优先被回收。

```
typedef struct redisObject {
    unsigned type:4;     # 类型
    unsigned encoding:4; # 编码
    void *ptr;           # 指向底层实现数据结构的指针
} robj;
```

type的取值

类型常量 | 对象的名称
--------|---------
REDIS\_STRING | 字符串对象
REDIS\_LIST | 列表对象
REDIS\_HASH | 哈希对象
REDIS\_SET | 集合对象
REDIS\_ZSET | 有序集合对象

对于redis保存的键值对来说，键总是一个字符串对象，而值可以是字符串对象、列表对象、哈希对象、集合对象、有序集合对象。


encoding的取值

类型常量 | 底层数据结构
--------|-----------
REDIS\_ENCODING\_INT | long类型的整数
REDIS\_ENCODING\_EMBSTR | embstr编码的简单动态字符串
REDIS\_ENCODING\_RAW | 简单动态字符串
REDIS\_ENCODING\_HT | 哈希表
REDIS\_ENCODING\_LINKEDLIST | 双向链表
REDIS\_ENCODING\_ZIPLIST | 压缩列表
REDIS\_ENCODING\_INTSET | 整数集合
REDIS\_ENCODING\_SKIPLIST | 跳跃表

每种类型至少使用了两种不同的编码，以下是不同类型和编码的对象

类型 | 编码 | 使用条件 
-----|-----|------
REDIS\_STRING | REDIS\_ENCODING\_INT | 保存的是整数值，且可以使用long类型存储
REDIS\_STRING | REDIS\_ENCODING\_EMBSTR | 字符串的长度小于等于32字节
REDIS\_STRING | REDIS\_ENCODING\_RAW | 字符串的长度大于32字节
REDIS\_LIST | REDIS\_ENCODING\_ZIPLIST | 1. 所有字符串长度都小于64字节 2. 保存的元素数量小于512个
REDIS\_LIST | REDIS\_ENCODING\_LINKEDLIST | 违反以上两条的任意一条则使用该编码
REDIS\_HASH | REDIS\_ENCODING\_ZIPLIST | 使用压缩列表实现的哈希对象
REDIS\_HASH | REDIS\_ENCODING\_HT | 使用哈希表实现的哈希对象
REDIS\_SET | REDIS\_ENCODING\_INTSET | 使用整数集合实现的集合对象
REDIS\_SET | REDIS\_ENCODING\_HT | 使用哈希表实现的集合对象
REDIS\_ZSET | REDIS\_ENCODING\_ZIPLIST | 使用压缩列表实现的有序集合对象
REDIS\_ZSET | REDIS\_ENCODING\_SKIPLIST | 使用跳跃表实现的有序集合对象

```
# 列表对象
list-max-ziplist-value       # 字符串最大长度
list-max-ziplist-entries     # 列表保存的最大元素数量
```

##### 字符串对象

##### 列表对象
##### 哈希对象
##### 集合对象
##### 有序集合对象


### 超时机制
redis里面的超时时间是以unix时间戳(2.6之后是毫秒)的形式保存的。过期的精度在0~1毫秒之间。

redis里key的过期方式有两种: 1.被动过期 2.主动过期

被动过期方式: 当客户端尝试访问一个key时，检查这个key是否超时。

主动过期方式: redis会每隔一段时间检查过期key集合里面的key是否超时。

redis主动检查过期的频率为每秒10次:

1. 从过期的key集合里面随机抽取20个进行测试
2. 删除所有过期的key
3. 如果过期的key超过25%，则再从第一步开始

在集群之间，对于过期的key，由主节点向从节点发送DEL操作，从而保证一致性问题。但是从节点也保存过期信息，这样当从节点被选举为主节点时，也可以执行过期操作。