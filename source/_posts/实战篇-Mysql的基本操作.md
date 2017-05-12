---
title: 实战篇-mysql的基本操作
date: 2017-03-26 20:17:46
tags:
	- mysql
---
### 服务启动
#### Ubuntu环境

```
/etc/init.d/mysql status
/etc/init.d/mysql start
/etc/init.d/mysql stop
/setc/init.d/mysql restart
```

#### CentOS环境

```
yum install mysql-server.x86_64
/etc/init.d/mysqld start
```

### 用户相关
mysql库 user表

```
select user, host from user;
create user username identified by 'password';     #创建用户
rename user username1 to username2;                #重命名用户
drop user username;                                #删除用户
use mysql;
update user set password=password("新密码") where user="root"; #更新用户密码
show grants for username;                          #查看用户的权限
GRANT USAGE ON *.* TO 'username'@'%'
grant select on blog.* to username;                #赋予用户权限
grant all on *.* to username@'%';                      #大招
revoke select on blog.* from username;             #收回用户权限
revoke all on *.* from username;                   #大招
flush privileges;                                  #立即生效
```
user表中host的含义

host|说明
----|----
%        |匹配所有主机
localhost|通过unix socket连接
127.0.0.1|通过tcp/ip, 且只能在本地连接
::1      |支持ipv6, 同127.0.0.1

权限表

权限|说明
-----------------------|---------------------------------
all                    | 所有权限
alter                  |
alter routine          |
create                 |
create routine         |
create temporary tables|
create user            |
create view            |
delete                 |
drop                   |
execute                |
file                   |
grant option           |
index                  |
insert                 | 可以使用create index和drop index
lock tables            |
process                |
reload                 | 使用flush
replication client     |
replication slave      |
select                 |
show databases         |
show view              |
shutdown               |
super                  |
update                 |
usage                  | 无访问权限

### 数据库相关

#### 建库建表
```
create database blog;         #创建数据库
create table ab (
    a int unsigned not null,
    b int unsigend not null
) engine=innodb default charset=utf8 auto_increment=1;  #建表
describe ab;                                            # 查看表信息
```
#### 索引相关
```
ALTER TABLE ab ADD INDEX index_name (column);  # 添加普通索引
ALTER TABLE ab ADD INDEX index_name (column1, column2);  # 添加联合索引
DROP INDEX index_name on ab;                             # 删除索引
```

### 系统配置相关
ubuntu环境，系统配置文件/etc/mysql/my.conf

```
show global variables;                  #查看所有系统全局变量
show global variables like "%timeout%"  #查看所有与超时相关的全局变量                 
```
#### 开放3306端口
修改/etc/mysql/mysql.conf.d/mysqld.cnf

```
#bind-address=127.0.0.1     #注释掉该行
```

### 新数据库设置

#### 服务配置
```
#启动服务后
mysql
use mysql;
update user set password=password("新密码") where user="root";
create user username identified by 'password';
grant all on *.* to username@'%';

#配置防火墙 /etc/sysconfig/iptables
-A INPUT -m state --state NEW -m tcp -p tcp --dport 3306 -j ACCEPT
service iptables restart
```

#### 建库建表
```
create database index_test;
create table ab (
    a int unsigned not null,
    b int unsigend not null
) engine=innodb default charset=utf8 auto_increment=1;
```