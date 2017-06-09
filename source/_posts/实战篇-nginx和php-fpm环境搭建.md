---
title: 实战篇-nginx和php-fpm环境搭建
date: 2017-06-07 15:46:25
tags:
    - 架构
---

#### centos

##### 安装服务
```
yum install nginx
yum install php-fpm
```

##### 配置服务

```
mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/xxx.conf

将xxx.conf文件内容修改为如下:
server {
    listen       80 default_server;
    root         path/to/home;

    index index.php;

    location ~ \.php$ {
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    error_page 404 /404.html;
        location = /40x.html {
    }

    error_page 500 502 503 504 /50x.html;
        location = /50x.html {
    }
}
```

在path/to/home目录下新建index.php文件

```
<?php
    echo "hello world";
?>
```

##### 启动服务

```
service php-fpm start
service nginx start
```