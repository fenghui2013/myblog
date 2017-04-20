---
title: 实战篇-java编程之maven
date: 2017-04-10 11:50:06
tags:
	- java
	- maven
---

[官方地址](http://maven.apache.org/)

### 下载及安装

下载二进制包，解压到自定义目录，比如third

```
tar xzvf apache-maven-3.5.0-bin.tar.gz
ln -s apache-maven-3.5.0 apache-maven
Mac下在.bash_profile文件下增加
export M2_HOME=$HOME/third/apache-maven
export PATH=$M2_HOME/bin:$PATH
mvn -v
```

### 配置
完成安装之后，会在HOME目录下生成.m2目录。
在.m2目录下有一个settings.xml文件。由于访问国外的源速度比较慢，所以在这里推荐阿里云的maven源。settings.xml文件的内容如下:

```
<mirror>
    <id>nexus-aliyun</id>
    <name>Nexus aliyun</name>
    <url>http://maven.aliyun.com/nexus/content/groups/public</url>
    <mirrorOf>*</mirrorOf>
</mirror> 
```

### 常用命令

```
mvn archetype:generate
mvn clean compile       # 编译
mvn clean test          # 测试
mvn clean install       # 安装资源到本地仓库
mvn clean deploy        # 发布资源到远程仓库
mvn dependency:list     # 查看所有依赖
mvn dependency:tree     # 查看所有依赖，以树的形式表示
mvn dependency:analyze  # 依赖分析 只会分析编译主代码和测试代码需要用到的依赖
```

[搜索库](http://mvnrepository.com/)