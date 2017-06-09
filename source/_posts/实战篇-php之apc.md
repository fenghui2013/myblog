---
title: 实战篇-php之apc
date: 2017-06-08 10:04:31
tags:
    - php
---

#### centos

```
yum install php-devel.x86_64
#yum install gcc automake php httpd httpd-devel
yum install php-pear
yum install php-devel.x86_64
yum install pcre-devel
yum install nginx
yum install php-fpm.x86_64
yum install mysql-server.x86_64
yum install git
yum install php-mysql.x86_64

pecl install apc
echo "extension=apc.so" >> /etc/php.ini
echo "apc.enabled=1" >> /etc/php.ini
```