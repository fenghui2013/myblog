---
title: 理论篇-innodb之事务
date: 2017-05-27 12:23:00
tags:
    - mysql
---

innodb的事务模型目标是结合多版本控制与传统的两阶段锁的各自的优点。innodb默认情况下，执行行级别的锁定和非锁定的一致性读。这与orcal有点类似。innodb里锁信息的存储是极其节省空间的。

#### 事务隔离级别

事务隔离级别的选取是在性能与结果的可靠性、一致性和再现性之间的一种取舍。

innodb提供了SQL:1992标准中所有的隔离级别:

* READ UNCOMMITED
* READ COMMITTED
* REPEATABLE READ
* SERIALIZABLE

innodb默认的隔离级别是REPEATBLE READ。

innodb使用不同的锁策略来支持每一种隔离级别。隔离级别越高，对锁的要求越高。如果对一致性要求比较高，则使用repeatable read隔离级别。若对一致性要求不高，或者为了降低锁的开销，可以使用read committed，甚至是read uncommitted。serializable隔离级别一般不会使用。

下面解释下innodb是怎么支持各个事务隔离级别的。

#### REPEATABLE READ

在同一个事务里的一致性读读取的是第一次读操作产生的快照。这意味着如果你在同一个事务里执行了几次非锁定的select语句，这些select语句是一致的。

对于锁定读(select ... for update或者select ... lock in share mode)，update和delete操作，锁定依赖于语句是在唯一索引上使用唯一搜索条件还是一种范围类型的搜索条件。

* 对于在唯一索引上使用唯一搜索条件的，innodb仅锁定发现的行记录。
* 对于其他的搜索，innodb会锁定被浏览过的索引范围，使用gap locks或者next-key locks来阻止其他会话向索引范围覆盖的间隙内插入。

#### READ COMMITTED

在同一个事务里的每一个一致性读设置和读取最新的快照。

对于锁定读(select ... for update和select ... lock in share mode)，update和delete操作，innodb只锁定索引记录，没有间隙锁定，因此允许在锁定行的左右自由的插入新的记录。Gap locking is only used for foreign-key constraint checking and duplicate-key checking.

由于gap locks被禁用了，所以当其他会话插入新的记录时，有可能会产生幻读。

如果你使用read committed事务隔离级别，必须使用row-base的二进制日志。

使用read committed有一些其他的影响:

* 对于update和delete操作，innodb仅在它更新或删除的行上加锁。在mysql执行了where条件匹配后，不匹配的行上的锁会被释放。这减少了死锁发生的可能性，但也会发生。
* 对于update操作，如果某行已经被锁定，innodb将执行一个伪一致性的读，返回最新被提交的版本，随后mysql使用该行来判断是否匹配update的where条件。如果匹配，mysql再次读取该行，这次innodb将会锁定该行或者是等待锁定该行。

考虑一个例子:

```
CREATE TABLE t (a INT NOT NULL, b INT) ENGINE = InnoDB;INSERT INTO t VALUES (1,2),(2,3),(3,2),(4,3),(5,2);COMMIT;
```
在这个例子里面，表没有索引，因此搜索和索引检查使用隐藏的集群索引来进行锁定。

假设一个客户端执行了如下的update操作:

```
SET autocommit = 0;UPDATE t SET b = 5 WHERE b = 3;
```

另一个客户端随后执行了如下的update操作:

```
SET autocommit = 0;UPDATE t SET b = 4 WHERE b = 2;
```

当innodb执行每个update操作时，首先会在每行上获取一个X锁，随后决定是否更新它。如果innodb不执行修改，则释放锁。否则的话，innodb将持有该锁直到事务结束。

当事务隔离级别是repeatable read时，第一个update操作会获取X锁并且不会释放任何一个锁。

```
x-lock(1,2); retain x-lockx-lock(2,3); update(2,3) to (2,5); retain x-lockx-lock(3,2); retain x-lockx-lock(4,3); update(4,3) to (4,5); retain x-lockx-lock(5,2); retain x-lock
```

当第二个update获取锁时，将会被阻塞(因此第一个更新已经锁定了所有的行)直到第一个update提交或回滚。

```
x-lock(1,2); block and wait for first UPDATE to commit or roll back
```

当事务隔离级别是read committed时，第一个update将会获取锁并且释放那些它不需要修改的行的锁。

```
x-lock(1,2); unlock(1,2)x-lock(2,3); update(2,3) to (2,5); retain x-lockx-lock(3,2); unlock(3,2)x-lock(4,3); update(4,3) to (4,5); retain x-lockx-lock(5,2); unlock(5,2)
```

对于第二个update，innodb执行一个伪一致性读操作，返回每一行最新的被提交的版本到mysql，随后mysql决定哪些行匹配update的where条件。

```
x-lock(1,2); update(1,2) to (1,4); retain x-lockx-lock(2,3); unlock(2,3)x-lock(3,2); update(3,2) to (3,4); retain x-lockx-lock(4,3); unlock(4,3)x-lock(5,2); update(5,2) to (5,4); retain x-lock
```

设置innodb\_locks\_unsafe\_for\_binlog等于使用read committed隔离级别。但是一般不要使用该选项。

#### READ UNCOMMITTED
在该事务隔离级别下会导致脏读，即读到其他事务修改但未提交的数据。其他的工作机制与read committed一样。

#### SERIALIZABLE
