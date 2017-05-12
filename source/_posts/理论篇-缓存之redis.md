---
title: 理论篇-redis
date: 2017-05-04 16:20:50
tags:
    - redis
---
### 命令

命令                        |   备注                    | 时间复杂度
---------------------------|---------------------------|----------
LLEN key|获取一个key指定的列表的长度|
LRANGE key start stop|获取key指定的列表里的指定范围的元素|
RPUSH key value [value ...]|追加一个或多个值到列表|
HLEN key|获取key指定的哈希表中field的数量|
HGETALL key|获取key指定的哈希表中所有的field和value|
BGSAVE|异步的数据集到硬盘|
BGREWRITEAOF|异步的重写持久化AOF|
ZRANGE key start stop [WITHSCORES]|获取key指定的有序集合里的指定范围的元素|O(lg(N)+M)
ZCARD key|获取key指定的有序集合里的元素数量| O(1)

### 数据结构与对象

redis中一切皆对象，共包含5种对象，分别为字符串对象(string object)、列表对象(list object)、哈希对象(hash object)、集合对象(set object)、有序集合对象(sorted set object)。

#### 字符串对象

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

#### 列表对象

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

#### 哈希对象
字典的底层数据结构是哈希表。

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

#### 有序集合对象
有序集合对象采用跳跃表作为底层实现。
