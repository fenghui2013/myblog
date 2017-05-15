---
title: 理论篇-mysql之innodb
date: 2017-05-15 10:51:20
tags:
    - mysql
---

###简介
innodb是第一个完整支持ACID事物的mysql存储引擎，行锁设计，支持MVCC，提供类似oracle风格的一致性非锁定读，支持外键，被设计用来最有效的利用内存和CPU。


#### 内存
innodb有许多内存块，其中包括buffer pool、redo log buffer、additional memory pool。这些内存块组成了一个大的内存池，负责如下工作:

* 维护所有进程/线程需要访问的多个内部数据结构
* 缓存磁盘上的数据，方便快速读取，并且对磁盘上的文件进行修改之前在这里缓存
* 重做日志缓冲
* ...

```
innodb_buffer_pool_size         # buffer pool
innodb_log_buffer_size          # log buffer
innodb_additional_mem_pool_size # additonal mem pool
```

**使用内存的方法**: 将数据库文件按页(每页16K)读取到内存池，然后按照最近最少使用算法(LRU)来保留在内存池中的数据。对数据的修改，首先修改内存池中的数据，此时该数据为脏数据，然后再以一定的频率将脏数据刷新到磁盘。

buffer pool里的数据页类型: index page、data page、undo page、insert buffer、自适应哈希索引(adaptive hash index)、lock info、data dictionary等

redo log buffer记录重做日志信息，然后以一定的频率(每秒)将其刷新到重做日志文件。

additional mem pool记录一些其他对象的信息。

#### 线程
innodb也有许多后台线程，默认情况下有4个IO线程、1个主线程、1个锁监控线程、1个错误监控线程。主要负责如下工作:

* 刷新内存中的数据，保证内存池中的内存缓存的是最近的数据
* 将已修改的数据刷新到磁盘文件，同时保证数据库发生异常的情况下innodb能恢复到正常运行状态

4个IO线程分别为insert buffer thread、log thread、read thread、write thread。

```
innodb_file_io_threads=4       # IO thread数量(linux下不可调整)
```
master thread 待看

### 索引
innodb支持两种索引: B+树索引和哈希索引。

#### 哈希索引
innodb引擎支持的哈希索引是自适应的，会根据表的使用情况自动生成哈希索引，不能人工干预。

#### B+树索引

B+树索引能找到的只是被查找数据行所在的页，将页加载到内存后再通过二分查找，最后得到查找的数据。

##### 插入操作
插入操作的三种情况

leaf page full | index page full | operations
---------------|-----------------|----------
No  | No | 直接将记录插入页节点
Yes | No | 1. 拆分leaf page<br>2. 将中间节点放入index page中<br>3. 小于中间节点的记录放左边<br>4. 大于等于中间节点的记录放右边
Yes | Yes| 1. 拆分leaf page<br>2. 小于中间节点的记录放左边<br>3. 大于中间节点的记录放右边<br>4. 拆分index page<br>5. 小于中间节点的记录放左边<br>6. 大于中间节点的记录放右边<br>7. 中间节点放入上一层index page

页的拆分意味着磁盘的操作，为了尽量避免磁盘操作，使用旋转来避免页拆分。

##### 删除操作
B+树使用填充因子(fill factor)控制树的删除变化，50%是填充因子的最小值。

leaf page below fill factor | index page below fill factor | oprations
----------------------------|------------------------------|----------
No  | No | 直接将记录从叶节点删除，如果该节点还是index page节点，则用该节点的右节点替代
Yes | No | 合并页节点及其兄弟节点，同时更新index page
Yes | Yes| 1. 合并叶节点机器兄弟节点<br>2. 更新index page<br>3. 合并index page及其兄弟节点

##### 聚集索引和非聚集索引
innodb存储引擎表中数据按照主键顺序存放。

聚集索引(clustered index)就是按照表中主键构造一个B+树，并且叶节点中存放着整张表的行记录数据，因此叶节点也是数据页。

数据页通过双向链表维护，页中的记录也通过双向链表维护。

非聚集索引(secondary index)是按照指定的关键字构造的一个B+树，并且叶节点存放的是行记录的主键。

如果在一个高度为3的非聚集索引树上查找数据，那么首先需要通过3次磁盘IO从非聚集索引找到指定主键。如果聚集索引高度同样为3，那么还需要通过3次磁盘IO从聚集索引找到要查找的数据。

#### 值得关注的地方

* 对于索引的添加和删除操作，mysql数据库先创建一张临时表，然后把数据导入临时表，删除原表，然后将临时表重命名为原来的表名，所以对于大表，此操作极为耗时。
    * 从版本innodb plugin开始，支持一种称为快速索引创建方法，仅限于非聚集索引。
* 

### 参考

* MySQL技术内幕: InnoDB存储引擎