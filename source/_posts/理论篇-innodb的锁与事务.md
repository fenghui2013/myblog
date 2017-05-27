---
title: 理论篇-innodb的锁与事务
date: 2017-05-26 20:40:03
tags:
    - mysql
---

### 锁
innodb实现了如下几种锁:

* share and exclusive locks
* intention locks
* record locks
* gap locks
* next-key locks
* insert intention locks
* AUTO-INC locks
* predicate locks for spatial indexes


#### Shared and Exclusive Locks

innodb实现两种类型的行级锁: shared locks(S) 和 exclusive locks(X)。

* S: 允许持有该锁的事务读取一行
* X: 允许持有该锁的事务更新或删除一行

如果事务T1在行r上获取了S锁，另一个事务T2也想获取行r上的锁，此时处理如下:

* 若T2请求的是S锁，则立即获取
* 若T2请求的是X锁，则不能立即获取，需要等待事务T1上S锁的释放

如果事务T1在行r上获取了X锁，不论事务T2想获取行r的什么类型的锁，都不能立即获取，需要等待事务T1上X锁的释放

#### Intention Locks

innodb支持多粒度锁定，多粒度锁定允许行级锁和表级锁同时存在。为了实现多粒度锁定，innodb引入了另外一种锁: 意向锁。在innodb里意向锁是一种表锁，表明了一个事务稍后想在某行上加的锁的类型(S锁还是X锁)。有两种类型的共享锁:

* IS: 事务T想在某些行上设置S锁
* IX: 事务T想在某些行上设置X锁

意向锁的协议如下:

* 在事务在表t的某一行上获取S锁之前，它必须首先获取一个IS锁或更强的锁
* 在事务获取X锁之前，它必须首先获取一个IX锁

-- | X | IX | S | IS
---|---|----|---|----
X | 冲突 | 冲突 | 冲突 | 冲突
IX | 冲突 | 不冲突 | 冲突 | 不冲突
S | 冲突 | 冲突 | 不冲突 | 不冲突
IS | 冲突 | 不冲突 | 不冲突 | 不冲突

如果一个正在请求的锁和已经存在的锁是不冲突的，则该锁立即被获取。如果冲突的话，则不能立即被获取。直到已经存在的锁被释放之后，才能获取。如果一直不能获取，那可能是死锁了，会报错。

因此，除了全表请求之外，意向锁不会阻塞任何事情。意向锁的主要目的是表明某人正在锁定某行或想锁定某行。

#### Record Locks

record locks是索引记录锁。例如**select c1 from t where c1=10 for update;**会阻止任何事务插入、更新或删除c1=10的行。

record locks总是锁定索引记录，尽管该表没有定义任何索引。对于这种情况，innodb会创建一个隐藏的集群索引，并使用该索引。


#### Gap Locks

gap locks是加在索引记录之间的间隙上的锁。该间隙包括记录之间、第一条之前、最后一条之后。例如**select c1 from t where c1 between 10 and 20 for update;**会阻止任何事务插入t.c1=15的数据，因为所有存在的值之间的间隙已经被锁定。

gap locks是性能和并发之间的权衡，被用在一些事务隔离级别里。

**select * from child where id = 100;**若id是唯一索引，则不触发gap locks。若id没有被索引或者不是唯一索引，则触发gap locks。

事务之间的gap locks永远不冲突。在innodb里的gap locks是"纯粹被禁止的"，那意味着他们仅阻止其他事务向该间隙插入值，他们不会阻止其他事务在同一个间隙上获得间隙锁。

gap locks可以被禁用，比如在**read committed**事务隔离级别下。

#### Next-Key Locks
next-key locks是索引记录上的record locks和索引记录之前的间隙上的gap locks的组合。

innodb执行行级别锁定的方式:当innodb搜索表索引时，会在搜索到的所有记录上添加锁。因此行级锁实际上就是索引记录锁。在索引记录上的next-key locks也会影响到在那个索引之前的间隙。比如: 如果一个会话在索引记录R上有一个锁，另一个会话不能立即在索引记录R之前(按照索引顺序)的间隙里插入一条新的索引记录。

假设有一个索引有如下值: 10, 11, 13和20。对于这个索引可能的next-key locks覆盖如下四个间隙。"("代表不包含该记录 "["代表包含该记录

```
(negative infinity, 10]
(10, 11]
(11, 13]
(13, 20]
(20, positive infinity]
```

默认情况下，innodb工作在repeatable read隔离级别下。在这种情况下，当尽心查找时，innodb使用next-key locks。next-key locks避免了幻读。



#### Insert Intention Locks

insert intention locks是在行插入之前被insert操作设置的一种gap lock。该锁表明如果多个插入同一索引间隙的事务插入的不是同一间隙内的相同的位置，则不必互相等待。

假设有一个索引，有4和7两个值。有两个事务分别想插入5和6这两个值。每个事务在插入行上获取X锁之前都优先获取了insert intention locks(锁定了4到7之间的间隙)。但是不会互相阻塞，因为行之间没有冲突。

#### AUTO-INC locks
AUTO-INC locks是一个特殊的表级别的锁。当表中有AUTO_INCREMENT列时事务自动使用该锁。当一个事务正在插入一个表，其他想插入该表的事务必须等待。因此，第一个事务插入的自增值是连续的。

innodb_autoinc_lock_mode控制了自增锁使用的算法。它允许你在自增的连续性上和并发插入之间做一个取舍。

#### Predicate Locks for Spatial Indexes

#### 查看

```
show engine innodb status;

>select * from t where a=200 lock in share mode;
RECORD LOCKS space id 26 page no 3 n bits 96 index PRIMARY of table `lock_test`.`t` trx id 2317 **lock mode S locks rec but not gap waiting**
Record lock, heap no 22 PHYSICAL RECORD: n_fields 4; compact format; info bits 0
 0: len 4; hex 800000c8; asc     ;;
 1: len 6; hex 00000000090c; asc       ;;
 2: len 7; hex 2b0000014801ca; asc +   H  ;;
 3: len 10; hex 66666620202020202020; asc fff       ;;

>select * from t where a=200 for update;
RECORD LOCKS space id 26 page no 3 n bits 96 index PRIMARY of table `lock_test`.`t` trx id 2317 **lock_mode X locks rec but not gap waiting**
Record lock, heap no 22 PHYSICAL RECORD: n_fields 4; compact format; info bits 0
 0: len 4; hex 800000c8; asc     ;;
 1: len 6; hex 00000000090c; asc       ;;
 2: len 7; hex 2b0000014801ca; asc +   H  ;;
 3: len 10; hex 66666620202020202020; asc fff       ;;
 
>select * from t where a<=200 lock in share mode;
RECORD LOCKS space id 26 page no 3 n bits 96 index PRIMARY of table `lock_test`.`t` trx id 2317 **lock mode S waiting**
Record lock, heap no 22 PHYSICAL RECORD: n_fields 4; compact format; info bits 0
 0: len 4; hex 800000c8; asc     ;;
 1: len 6; hex 00000000090c; asc       ;;
 2: len 7; hex 2b0000014801ca; asc +   H  ;;
 3: len 10; hex 66666620202020202020; asc fff       ;;
 
>select * from t where a<=200 for update;
RECORD LOCKS space id 26 page no 3 n bits 96 index PRIMARY of table `lock_test`.`t` trx id 2317 **lock_mode X waiting**
Record lock, heap no 22 PHYSICAL RECORD: n_fields 4; compact format; info bits 0
 0: len 4; hex 800000c8; asc     ;;
 1: len 6; hex 00000000090c; asc       ;;
 2: len 7; hex 2b0000014801ca; asc +   H  ;;
 3: len 10; hex 66666620202020202020; asc fff       ;;
 
 
>update t set b="ttt" where a=200;
RECORD LOCKS space id 26 page no 3 n bits 96 index PRIMARY of table `lock_test`.`t` trx id 2319 **lock_mode X locks rec but not gap waiting**
Record lock, heap no 22 PHYSICAL RECORD: n_fields 4; compact format; info bits 0
 0: len 4; hex 800000c8; asc     ;;
 1: len 6; hex 00000000090c; asc       ;;
 2: len 7; hex 2b0000014801ca; asc +   H  ;;
 3: len 10; hex 66666620202020202020; asc fff       ;;
 
>update t set b="ttt" where a<=200;
RECORD LOCKS space id 26 page no 3 n bits 96 index PRIMARY of table `lock_test`.`t` trx id 2319 **lock_mode X waiting**
Record lock, heap no 22 PHYSICAL RECORD: n_fields 4; compact format; info bits 0
 0: len 4; hex 800000c8; asc     ;;
 1: len 6; hex 00000000090c; asc       ;;
 2: len 7; hex 2b0000014801ca; asc +   H  ;;
 3: len 10; hex 66666620202020202020; asc fff       ;;
 
>select * from t where a<=200 lock in share mode;
>insert into t values(20, "aaa", "aaa");
RECORD LOCKS space id 28 page no 3 n bits 72 index PRIMARY of table `lock_test`.`t` trx id 2345 **lock_mode X locks gap before rec insert intention waiting**
Record lock, heap no 3 PHYSICAL RECORD: n_fields 5; compact format; info bits 0
 0: len 4; hex 800000c8; asc     ;;
 1: len 6; hex 000000000928; asc      (;;
 2: len 7; hex 3d000001340410; asc =   4  ;;
 3: len 10; hex 72727220202020202020; asc rrr       ;;
 4: SQL NULL;
```

### 事务模型

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

##### REPEATABLE READ

在同一个事务里的一致性读读取的是第一次读操作产生的快照。这意味着如果你在同一个事务里执行了几次非锁定的select语句，这些select语句是一致的。

对于锁定读(select ... for update或者select ... lock in share mode)，update和delete操作，锁定依赖于语句是在唯一索引上使用唯一搜索条件还是一种范围类型的搜索条件。

* 对于在唯一索引上使用唯一搜索条件的，innodb仅锁定发现的行记录。
* 对于其他的搜索，innodb会锁定被浏览过的索引范围，使用gap locks或者next-key locks来阻止其他会话向索引范围覆盖的间隙内插入。

##### READ COMMITTED

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

##### READ UNCOMMITTED
在该事务隔离级别下会导致脏读，即读到其他事务修改但未提交的数据。其他的工作机制与read committed一样。

##### SERIALIZABLE