---
title: 理论篇-innodb的多版本控制
date: 2017-05-27 14:01:48
tags:
    - mysql
---

innodb是一个多版本存储引擎:为了支持事务功能(比如并发和回滚)，它保留已更新数据的一个或多个旧版本。这些信息被存储在表空间的rollback segment数据结构内。innodb使用这些信息来完成事务回滚操作或者为了一致性读而获取某些行的更早版本。

内部实现上，innodb在每行上增加如下三个字段:

* DB\_TRX\_ID，6个字节大小，最后插入或更新该行的事务id。删除操作也被当做一种更新操作来处理，本质是更新该行的某一个特定的位来表明该行已被删除。
* DB\_ROLL\_PTR，7字节大小，回滚指针。该指针指向一个被写到rollback segment的undo日志记录。
* DB\_ROW\_ID，6字节大小，行id。该字段是一个单调递增字段。如果innodb自动生成了一个集群索引，该索引会包含该字段的值。否则的话，该字段不会出现在任何索引上。

rollback segment里的undo日志被分为insert undo日志和update undo日志。insert undo日志只在事务回滚的时候需要。事务提交之后，立即删除。update undo日志除了用在事务回滚上，也被用在一致性读上。当没有事务需要利用undate undo日志来构建之前版本的行记录时，这些update undo日志也会被删除。

定期提交你的事务，包括那些一致性读的这些事务。否则的话，innodb不会删除update undo日志。rollback segment可能会越来越大。


rollback segment里的undo日志记录的物理大小比相应的插入的或更新的行要小。你可以使用这些信息来计算rollback segment所需要的空间大小。

在innodb的多版本模式下，当你使用sql语句删除的时候，该行不会被物理的删除。只有当删除操作的update undo日志记录被删除的时候，innodb才会物理上删除相应的行和它的索引。该删除操作被称为purge。

当在一个表中频繁的进行插入和删除操作的时候，purge线程将停止工作并倒计时，表会因为所有的已删除的行而变得越来越大。

```
innodb_max_purge_lag        # 该选项设置purge线程最大的等待时间，默认是0
```

#### Multi-Versioning and Secondary Indexes(待考究)

innodb的MVCC对第二索引与集群索引的处理不同。在集群索引中的记录被实地(in-place)更新并且隐藏列指向了undo日志。第二索引没有隐藏列也不会实地(in-place)更新。

当第二索引的列被更新的时候，旧的第二索引记录有一个删除标记，新的记录被插入，被标记删除的记录最终会被清除。
