---
title: 理论篇-redis之各种命令
date: 2017-05-20 18:55:48
tags:
    - redis
---

### 命令

#### 字符串对象相关命令
命令 | 解释 | 时间复杂度 | 特别说明
----|-----|----------|-----------
SET key value [EX seconds] [PX milliseconds] [NX &#124; XX]| | O(1) | 覆写之前的值，若有过期时间，则删除
SETEX key seconds value | | O(1) | 原子操作
SETNX key value | | O(1) |
GET key | | O(1) |
APPEND key value |  | O(1) |   
STRLEN key | 返回key指定的字符串的长度 | |
SETRANGE key offset value | 覆写字符串的一部分 | O(1) 
GETRANGE key start end | 获取字符串的一部分 | O(N)
INC key | | O(1)
INCBY key increment | | O(1)
INCBYFLOAT key increment | | O(1)
DECR key | | O(1)
DECRBY key decrement | | O(1)

[Pattern: Time series](https://redis.io/commands/append)

[Design pattern: Locking with SETNX](https://redis.io/commands/setnx)

#### 列表对象相关命令

命令 | 解释 | 时间复杂度 | 特别说明
----|-----|----------|-----------
LINDEX key index | 返回指定索引处的值 | O(N) | 表头从0开始 表尾从-1开始
LINSERT key BEFORE &#124; AFTER pivot value | 在列表某一项之前或之后添加元素 | O(N) |
LLEN key|获取一个key指定的列表的长度| O(1) |
LPOP | 移除并返回列表的第一个元素 | O(1) |
LPUSH key value [value ...]| 插入一个或多个值到表头| O(1) | 若key指定的列表不存在，则创建一个空的列表
LPUSHX key value | 插入一个值到表头 | O(1) | 若key指定的列表不存在，则什么也不做
LRANGE key start stop|获取key指定的列表里的指定范围的元素|
LREM key count value | 删除列表中的元素 | O(N)| count>0 从表开始 count<0从表尾开始 count=0 删除所有
LSET key index value | 设置索引处的值 | |
LTRIM key start stop | 截断列表 | O(N) |
RPOP | 移除并返回列表的最后一个元素 | O(1) |
RPOPLPUSH source destination | 移除并返回source指定的列表的最后一个节点并且将该节点放入destination指定的列表的表头 | O(1) | 原子操作 
RPUSH key value [value ...]|插入一个或多个值到表尾 | O(1) | 若key指定的列表不存在，则创建一个空的列表
RPUSHX key value | 追加一个值到列表 | O(1) | 若key指定的列表不存在，则什么也不做

[Pattern: Reliable queue](https://redis.io/commands/rpoplpush#pattern-reliable-queue)

#### 字典相关命令
命令 | 备注 | 时间复杂度
-----|-----|----------
HLEN key|获取key指定的哈希表中field的数量|
HGETALL key|获取key指定的哈希表中所有的field和value|

#### 集合相关命令
命令 | 备注 | 时间复杂度
-----|-----|----------
ZADD key [NX &#124; XX] [CH] [INCR] score member [score member ...] | 向key指定的有序集合中添加带有分数的字段| O(lg(N))
ZRANGE key start stop [WITHSCORES]| 获取key指定的有序集合里的指定范围的元素 |O(lg(N)+M)
ZCARD key|获取key指定的有序集合里的元素数量| O(1)

#### 事务相关命令

命令 | 备注 | 时间复杂度
-----|-----|----------
MULTI | 事务的开始标记 |
EXEC | 执行所有当前事务中已入队的命令 |  

#### 其它命令
命令 | 解释 | 时间复杂度 | 特别说明
-----|-----|----------|---------
BGSAVE|异步的数据集到硬盘|
BGREWRITEAOF|异步的重写持久化AOF|
TYPE key | 返回key指定的值的类型，可能是string, list, set, zset, hash | O(1)
OBJECT sumcommand [arguments [arguments ...]] | 查看与key相关的redis对象的内部 | O(1)

#### 超时时间相关命令
命令 | 解释 | 时间复杂度 | 特别说明
-----|-----|----------|---------
EXPIRE key seconds | 设置key的超时时间 | O(1) | 对key指定的值得修改操作不会影响到超时时间
PEXPIRE key milliseconds | 设置key的超时时间 | O(1) | 毫秒单位
EXPIREAT key timestamp | 设置key的超时时间 | O(1) | 设置秒级时间戳
PEXPIREAT key milliseconds-timestamp | 设置key的超时时间 | O(1) | 设置毫秒级时间戳
PERSISIT key | 删除key上的超时时间 | O(1) | 