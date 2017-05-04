---
title: 理论篇-缓存之redis
date: 2017-05-04 16:20:50
tags:
    - 缓存
---
### 命令

```
LLEN key                    # 获取一个key指定的列表的长度
LRANGE key start stop       # 从一个key指定的列表里获取范围内的元素
RPUSH key value [value ...] # 追加一个或多个值到列表
```

### 数据结构与对象

redis中一切皆对象，共包含5种对象，分别为字符串对象(string object)、列表对象(list object)、字典对象(dict object)、集合对象(set object)、有序集合对象(sorted set object)。

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

#### 字典对象
