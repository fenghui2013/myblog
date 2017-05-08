---
title: 实战篇-消息队列之RabbitMQ
date: 2017-03-27 21:53:44
tags:
	- 实战
	- 消息队列
	- RabbitMQ
---
### 安装

```
yum install epel-release  # 安装epel源
yum install rabbitmq
```

epel是Fedora小组维护的软件仓库，为CentOS提供默认不提供的软件包。

### 启动与停止
```
rabbitmq-server                        # 启动服务
rabbitmq-server -detached              # 以守护进程的方式启动服务
rabbitmqctl stop                       # 关闭应用和节点
rabbitmqctl stop-app                   # 只关闭应用
rabbitmqctl stop -n rabbit@[hostname]  # 关闭应用和节点
```

### 配置文件
配置文件目录:/etc/rabbitmq/rabbitmq.config。配置文件内容格式如下:

```
[
	{mnesia, [{dump_log_write_threshold, 1000}]},
	{rabbit, [{vm_memory_high_watermark, 0.4}]}
]
```

配置|值类型|默认值|备注
------------------------|-----------------|--------------------|----------------
dump\_log_write\_threshold| int             | 100    |
tcp\_listeners            | [{"ip", port}] | [{"0.0.0.0", 5672}] |
ssl\_listeners            | [{"ip", port}] | 空                  |
ssl\_options              | [{key, value}] | 空                  |
vm\_memory\_high\_watermark| 十进制百分数     | 0.4                 |
msg\_store\_file\_size\_limit| int 字节      | 16777216            |
queue\_index\_max\_journal\_entries| int     | 262144              |

### 管理命令
通过运行rabbitmqctl -h可获得命名的具体使用方法。

```
rabbitmqctl -h
```

### 安装之后需执行的命令

```
rabbitmqctl [-n node_name] add_user username password
rabbitmqctl [-n node_name] set_user_tags username administrator
rabbitmqctl [-n node_name] set_permissions -p / username ".*" ".*" ".*"
rabbitmq-plugins [-n node_name] enable rabbitmq_management              # 开启web管理插件
```