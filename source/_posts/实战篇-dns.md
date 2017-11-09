---
title: 实战篇-dns
date: 2017-11-03 15:20:43
tags:
    - dns
---

#### system info

```
[root@centos-6-9 ~]# lsb_release -a
LSB Version:	:base-4.0-amd64:base-4.0-noarch:core-4.0-amd64:core-4.0-noarch:graphics-4.0-amd64:graphics-4.0-noarch:printing-4.0-amd64:printing-4.0-noarch
Distributor ID:	CentOS
Description:	CentOS release 6.9 (Final)
Release:	6.9
Codename:	Final
```

#### install

```
yum install bind bind-chroot
```

#### configure

/etc/named.conf

```
options {
	listen-on port 53 { any; };
	listen-on-v6 port 53 { ::1; };
	directory 	"/var/named";
	dump-file 	"/var/named/data/cache_dump.db";
	statistics-file "/var/named/data/named_stats.txt";
	memstatistics-file "/var/named/data/named_mem_stats.txt";
	allow-query     { any; };
	recursion yes;
	allow-transfer { none; };
};

zone "." IN {
	type hint;
	file "named.ca";
};

zone "centos.dog" IN {
    type master;
    file "named.centos.dog";
};

//zone "3.0.10.in-addr.arpa" {
//    type master;
//    file "named.10.0.3";
//}
```

/var/named/named.centos.dog

```
$TTL 600
@                       IN SOA master.centos.dog. dog.www.centos.dog. (2017110301 3H 15M 1W 1D)
@                       IN NS   master.centos.dog.
master.centos.dog.      IN A    10.0.3.15
@                       IN MX 10 www.centos.dog.


www.centos.dog.         IN A 10.0.3.15
linux.centos.dog.       IN CNAME www.centos.dog.
ftp.centos.dog.         IN CNAME www.centos.dog.


;test.centos.dog        IN A 10.0.3.
```

#### start stop

```
/etc/init.d/named start|stop|restart|status
```