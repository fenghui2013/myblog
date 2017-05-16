---
title: 实战篇-mysql之性能调优
date: 2017-05-15 19:02:21
tags:
    - mysql
---

```
mysql> show engine innodb status \G
*************************** 1. row ***************************
  Type: InnoDB
  Name:
Status:
=====================================
170515 18:57:08 INNODB MONITOR OUTPUT
=====================================
Per second averages calculated from the last 55 seconds
----------
SEMAPHORES
----------
OS WAIT ARRAY INFO: reservation count 7, signal count 7
Mutex spin waits 0, rounds 0, OS waits 0
RW-shared spins 14, OS waits 7; RW-excl spins 0, OS waits 0
------------
TRANSACTIONS
------------
Trx id counter 0 769
Purge done for trx's n:o < 0 0 undo n:o < 0 0
History list length 0
LIST OF TRANSACTIONS FOR EACH SESSION:
---TRANSACTION 0 0, not started, process no 1588, OS thread id 140663937918720
MySQL thread id 2, query id 47 localhost root
show engine innodb status
--------
FILE I/O
--------
I/O thread 0 state: waiting for i/o request (insert buffer thread)
I/O thread 1 state: waiting for i/o request (log thread)
I/O thread 2 state: waiting for i/o request (read thread)
I/O thread 3 state: waiting for i/o request (write thread)
Pending normal aio reads: 0, aio writes: 0,
 ibuf aio reads: 0, log i/o's: 0, sync i/o's: 0
Pending flushes (fsync) log: 0; buffer pool: 0
0 OS file reads, 38 OS file writes, 16 OS fsyncs
0.00 reads/s, 0 avg bytes/read, 0.00 writes/s, 0.00 fsyncs/s
-------------------------------------
INSERT BUFFER AND ADAPTIVE HASH INDEX  # 插入缓冲和自适应哈希索引
-------------------------------------
Ibuf: size 1(已经合并记录页的数量), free list len 0(空闲列表的长度), seg size 2(当前插入缓冲的大小:2*16KB),
0 inserts(插入的记录数), 0 merged recs(合并的页的数量), 0 merges(合并的次数)
Hash table size 17393(哈希表槽的数量), node heap has 1 buffer(s)
0.00 hash searches/s(每秒多少次哈希查找), 0.00 non-hash searches/s(每秒多少次非哈希查找)
---
LOG
---
Log sequence number 0 44233
Log flushed up to   0 44233
Last checkpoint at  0 44233
0 pending log writes, 0 pending chkp writes
11 log i/o's done, 0.00 log i/o's/second
----------------------
BUFFER POOL AND MEMORY
----------------------
Total memory allocated 20375354; in additional pool allocated 652800
Dictionary memory allocated 33320
Buffer pool size   512             # 缓冲的总大小，每个代表一个数据页(16K) 512*16/1024=8M
Free buffers       333             # 空闲的数量
Database pages     178             # 已使用的数量
Modified db pages  0               # 脏页的数量
Pending reads 0
Pending writes: LRU 0, flush list 0, single page 0
Pages read 0, created 178, written 189
0.00 reads/s, 0.00 creates/s, 0.00 writes/s
No buffer pool page gets since the last printout
--------------
ROW OPERATIONS
--------------
0 queries inside InnoDB, 0 queries in queue
1 read views open inside InnoDB
Main thread process no. 1588, id 140663815362304, state: waiting for server activity
Number of rows inserted 0, updated 0, deleted 0, read 0
0.00 inserts/s, 0.00 updates/s, 0.00 deletes/s, 0.00 reads/s
----------------------------
END OF INNODB MONITOR OUTPUT
============================

1 row in set (0.00 sec)
```

```
mysql> show index from ab \G
*************************** 1. row ***************************
       Table: ab           # 表名
  Non_unique: 1            # 非唯一
    Key_name: idx_a        # 索引名
Seq_in_index: 1            # 索引列的位置(联合索引中使用)
 Column_name: a            # 索引的列
   Collation: A            # 列以什么方式存放在索引中 A(有序)或NULL(无序)
 Cardinality: 2            # 索引中唯一值的估值，非常关键，评判一个索引是否有必要
    Sub_part: NULL         # 是否列的一部分
      Packed: NULL         # 是否被压缩
        Null:              # 索引的列是否还有NULL
  Index_type: BTREE        # 索引类型
     Comment:              # 注释
1 row in set (0.00 sec)

优化器会根据cardinality的值来判断是否使用索引。
analyze table tbl_name;  # 会更新cardianlity的值
```

```
mysql> explain select * from ab where a = 1 \G
*************************** 1. row ***************************
           id: 1
  select_type: SIMPLE              # 选择类型
        table: ab                  # 表名
         type: ref                 # 
possible_keys: idx_a               # 可使用的索引
          key: idx_a               # 使用的索引
      key_len: 4                   # 索引的长度
          ref: const               # 
         rows: 1                   # 行数
        Extra:
1 row in set (0.00 sec)

查询优化器根据rows来判断是否使用索引，或执行全表扫描。
```