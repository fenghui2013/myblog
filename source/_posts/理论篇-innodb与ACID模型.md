---
title: 理论篇-innodb与ACID模型
date: 2017-05-27 13:34:31
tags:
    - mysql
---

ACID模型是一系列数据库设计准则，该准则强调可靠性。InnnDB存储引擎接近于ACID模型，因此不论是软件故障还是硬件故障，数据的可靠性都能得到保障。你能通过调整mysql的设置在可靠性和更高的性能之间做一些取舍。

我们看下InnoDB存储引擎是怎么满足ACID模型的。

#### Atomicity

原子性主要涉及InnoDB的事务。相关的mysql功能如下:

* autocommit设置
* commit语句
* rollback语句
* 表INFORMATION_SCHEMA中的数据

#### Consistency

一致性主要涉及InnoDB用来保护数据的内部处理。相关的mysql功能如下:

* innodb的doublewrite buffer
* innodb的crash recovery

#### Isolation

隔离性主要涉及InnoDB的事务。相关的mysql功能如下:

* autocommit设置
* SET ISOLATION LEVEL语句
* innodb锁的底层实现细节。性能调优时，可参考表INFORMATION_SCHEMA中的数据

#### Durability

持久性涉及到了mysql与特定的硬件。相关的mysql功能如下:

* innodb的doublewrite buffer。可通过innodb_doublewrite选项配置
* 配置选项innodb_flush_log_at_trx_commit
* 配置选项sync_binlog
* 配置选项innodb_file_per_table
* 写缓冲到存储设备上，例如普通硬盘，SSD或者RAID磁盘阵列
* 存储设备上的备用电池
* 操作系统，特别是支持fsync系统调用
* 不间断的电力供应
* 备份策略
* 对于分布式应用来说，可靠的网络