---
title: 理论篇-mysql之innodb
date: 2017-05-15 10:51:20
tags:
    - mysql
---

### 简介
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

#### 关键特性

##### 插入缓冲(insert buffer)
插入缓冲是为了提高对非聚集索引的操作的，首先判断非聚集索引页是否在缓冲池中，如果在，则直接插入。否则将数据放入插入缓冲区中，然后以一定的频率执行插入缓冲和非聚集索引叶子节点的合并操作。需满足如下两个条件:

* 索引是非聚集索引
* 不是唯一索引

```
IBUF_POOL_SIZE_PRE_MAX_SIZE 2  # 插入缓冲占总缓冲区的多少
```
**为了插入速度的提升**

##### 双写(double write)
double write由两部分组成: 1. 内存中的doublewrite buffer，大小为2MB；另一部分是物理磁盘上共享表空间中连续的128个页，即两个区，大小同样为2M。

![mysql_double_write](/img/mysql_double_write.png)

运行原理:当缓冲池中的脏页刷新时，并不直接写磁盘，而是通过memcpy函数将脏页先拷贝到内存中的doublewrite buffer，之后通过两次磁盘写操作将数据持久化到硬盘，每次写入数据量1M。第一次写到共享表空间的物理磁盘上，然后马上调用fsync函数，同步磁盘，由于页是连续的，所以执行速度很快。第二次写到各个表空间文件中，此时的写入则是离散的。

```
innodb_doublewrite=ON            # 双写的开关

show global status like "innodb%";
Innodb_dblwr_pages_written       # 写入的页的数量
Innodb_dblwr_writes              # 写磁盘的次数
```

如果数据库在将页写入磁盘的过程中崩溃了，在恢复过程中，innodb引擎可以从共享表空间的doublewrite中找到该页的副本，将其拷贝到表空间里，再应用重做日志。

**为了数据的安全**

##### 自适应哈希索引
自适应哈希索引不需要将整个表都建索引，innodb会自动根据访问的频率和模式来为某些页建立哈希索引。

```
innodb_adaptive_hash_index=ON        # 自适应哈希索引的开关
```

**为了查询速度的提升**

#### 启动、关闭和恢复

innodb_fast_shutdown参数决定了innodb关闭时执行的操作，默认为0。

innodb_fast_shutdown | 含义
---------------------|-----
0 | 完成所有的full purge和merge insert buffer操作
1 | 不做如上操作，只刷新缓冲池中的脏数据到磁盘
2 | 不做如上操作，只将日志写入到日志文件

innodb_force_recovery参数决定了innodb启动时执行的操作，默认为0。

innodb_force_recovery | 含义
----------------------|-----
0 | 执行所有的恢复操作
1 | 忽略检查到的corrupt页
2 | 阻止主线程的执行，如主线程需要执行full purge操作，会导致crash
3 | 不执行事务回滚操作
4 | 不执行插入缓冲的合并操作
5 | 不查看撤销日志，会将未提交的事务视为已提交
6 | 不执行回滚的操作

### 文件
#### 参数文件

```
SET
| [global | session] system_var_name=expr
| [@@global. | @@session. | @@]system_var_name=expr # 设置参数
```

#### 日志文件
##### 错误日志
对mysql的启动、运行、关闭过程进行了记录。

```
show variables like "log_error";  # 查看错误日志的路径
```
##### 二进制日志

待看

```
log_bin=OFF                       # 二进制日志开关
show variables like "datadir";    # 日志路径
```
##### 慢查询日志
主要用来优化sql查询。

```
long_query_time=10       # 慢查询的阈值(单位:微妙)

log_output=FILE                    # 指定慢查询的记录格式 FILE TABLE
log_queries_not_using_indexes=OFF  # 没有使用索引的查询也被当做慢查询
log_slow_queries=OFF               # 慢查询的开关
slow_query_log=OFF                 # 慢查询日志开关
slow_query_log_file=""             # 慢查询日志路径

mysqldumpslow                      # 该工具可以帮助解析慢查询日志
```
#### 表结构定义文件
以frm为后缀名结尾的文件记录了表的结构定义。该文件还用来存放试图的定义。
#### innodb存储引擎文件
##### 重做日志文件
ib\_logile0和ib\_logfile1是innodb存储引擎的重做日志文件，主要用来记录innodb引擎的事务日志。

![mysql_redo_log](/img/mysql_redo_log.png)

如图所示，重做日志首先写入重做日志缓冲区中，然后以一定的频率刷新到磁盘。主线程每秒将重做日志缓冲写入到磁盘的重做日志文件，不论事务是否已提交。innodb_flush_log_at_trx_commit参数决定了在事务提交时，对重做日志的处理。

innodb_flush_log_at_trx_commit | 含义
-------------------------------|-----
0 | 等待主线程每秒的刷新
1 | commit时将重做日志缓冲同步到磁盘
2 | commit时将重做日志异步写到磁盘

```
innodb_log_file_size       # 重做日志文件的大小
innodb_log_files_in_group  # 日志文件组中重做日志文件的数量 默认为2
innodb_mirrored_log_groups # 日志镜像文件组的数量，默认为1
innodb_log_group_home_dir  # 日志文件组所在路径
```

##### 表空间文件
ibdata1即为默认的表空间文件。innodb_file_per_table参数可设置每张表一个表空间文件，单独的表空间文件以ibd为后缀，这些文件只记录了该表的数据、索引和插入缓冲等信息，其他信息还是要存放到默认的表空间文件中。

```
innodb_file_per_table=0         # 每张表一个文件的开关

[mysqld]
innodb_data_file_path=datafile_spec1[;datafile_spec2]...
innodb_data_file_path=/db/ibdata1:2000M;/db2/ibdata2:2000M:autoextend
```

### 表
innodb存储引擎表中，每张表都有个主键，如果在创建表时没有显式的定义主键(primary key)，则会按如下方式选择或创建主键:

*  表中是否有非空的且为唯一的列，若有，则该列即为主键
*  不符合上述条件，则自动创建一个6个字节大小的指针

#### 逻辑存储结构

所有数据被逻辑的存放在一个空间中，该空间被称为表空间(tablespace)。表空间又由段(segment)、区(extent)、页(page)组成。如下图所示:

![mysql_tablespace](/img/mysql_tablespace.png)

常见的段有数据段、索引段、回滚段等，其中数据段即为B+树的叶节点，索引段即为B+树的非叶节点。

区是由64个连续的页组成的，每个页的大小为16KB，即每个区的大小为1MB。

每页可容纳的记录数(即行数)为200~16KB/2之间。

#### 物理存储结构

mysql5.1之后，有两种存放行记录的格式: Compact和Redundant，其中Compact是新格式。

```
show table status \G           # 查看表信息
```

```
Compact格式如下:
变长字段实际长度列表|NULL标志位|头信息|列1数据|列2数据|...

变长字段实际长度列表，当列的长度小于255时，用1字节表示，若大于255时，用2字节表示，最大不可超过2个字节(这就是为什么varchar不能超过65535的原因)。
NULL标志位，该位表示了该行数据中是否有NULL标志位 根据需要，可能为多字节
头信息，固定占用5字节，每位的如下表所示
最后是每列的数据，NULL不占用列数据

每行还有两个隐藏列: 事务ID列和回滚指针列，分别占用6字节和7字节，若没有primary key，则每行还会增加一个6字节的rowId列。
```

名称 | 大小(bit) | 含义
----|----------|----
() | 1 | 未知
() | 1 | 未知
deleted_flag | 1 | 该行是否已被删除
min_rec_flag | 1 | 若该记录是预先被定义为最小记录则为1
n_owned | 4 | 该记录拥有的记录数
heap_no | 13 | 索引堆中该记录的排序记录
record_type | 3 | 记录类型 000:普通 001:B+树节点指针 002:Infinum 003: Supermum 1xx=保留
next_recorder | 16 | 页中下一条记录的相对位置

```
varchar(N)      # 其中varchar最大长度为65535个字节，其中N指的是字符个数
```

### 索引
innodb支持两种索引: B+树索引和哈希索引。

#### 哈希索引
innodb引擎支持的哈希索引是自适应的，会根据表的使用情况自动生成哈希索引，不能人工干预。**最终目的是加速对内存数据即缓存的查找**。

```
innodb_adaptive_hash_index=ON     # 自适应哈希索引启用开关
```

#### B+树索引

B+树索引能找到的只是被查找数据行所在的页，将页加载到内存后再通过二分查找，最后得到查找的数据。**最终目的是加速对磁盘即数据库文件的查找**。

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


##### 预读取

顺序预读取: 一个区(由64个页组成)中多少页被顺序访问时，innodb引擎会读取下一个区的所有页。

```
innodb_read_ahead_threshold=56   # 预读取阈值配置
```
##### 辅助索引

##### 联合索引


##### 值得关注的地方

* 对于索引的添加和删除操作，mysql数据库先创建一张临时表，然后把数据导入临时表，删除原表，然后将临时表重命名为原来的表名，所以对于大表，此操作极为耗时。
    * 从版本innodb plugin开始，支持一种称为快速索引创建方法，仅限于非聚集索引。
* 索引的使用原则: 高选择性和取出表中少部分数据。
* 即使访问的是高选择性字段，但是由于查询命中的数据占表中大部分(经验值20%)数据时，此时查询优化器也会不走索引，而执行全表扫描。



### 参考

* MySQL技术内幕: InnoDB存储引擎