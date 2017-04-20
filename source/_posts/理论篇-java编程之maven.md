---
title: 理论篇-java编程之maven
date: 2017-04-10 13:49:25
tags:
	- java
	- maven
---
印象中第一次接触maven是在2013年，到2017年才真正系统得学习了一下。

### Maven本身
解压后maven目录下包含如下内容:

```
bin            # mvn运行的脚本
boot           # mvn的类加载器
conf           # 配置文件，其中包含settings.conf
lib            # 真正的mvn及第三方类库
LICENSE.txt    # 软件许可证
NOTICE.txt     # mvn使用的第三方软件
README.txt     # mvn简介
```

### 坐标系统

```
groupId           # 必须 当前项目隶属的实际项目 一般为 组织.实际项目
artifactId        # 必须 实际项目中的一个maven项目 一般为实际项目-模块
version           # 必须 当前模块的版本
packaging         # 可选 打包方式
classifier        # 附属构建 暂时还没弄明白
```

### 依赖范围
maven在编译项目主代码的时候需要一套classpath，编译和执行测试的时候需要另一套classpath，实际运行项目的时候又会使用另一个classpath。依赖范围就是针对这三种classpath的。

依赖范围| 编译 | 测试 | 运行 | 例子
---------|-----|------|-----|-----
compile  |  Y  |  Y   |  Y  | spring-core
test     |  N  |  Y   |  Y  | JUnit
provided |  Y  |  Y   |  N  | servlet-api
runtime  |  N  |  Y   |  Y  | JDBC
system   |  Y  |  Y   |  N  | 本地的，maven之外的类库文件

#### 传递性依赖
当依赖产生冲突的时候，按序依据如下规则进行解决:

* 路径最近者优先
* 第一声明者优先

注意:可选依赖不被传递。

### 仓库
maven的仓库分为本地仓库和远程仓库两种。当编译项目时，优先从本地仓库获取资源，若本地仓库没有，则从远程仓库获取，若远程仓库也没有，则报错。

### 从仓库解析依赖的机制

1. 当依赖的范围是system时，直接从本地文件系统解析构件
2. 根据依赖坐标计算仓库路径后，尝试直接从本地仓库寻找构件，如果发现相应构件，则解析成功
3. 在本地仓库不存在相应构件的情况下，如果依赖的版本是显式的发布版本构件，则遍历所有的远程仓库，发现后，下载并解析使用
4. 如果依赖的版本是RELEASES或LATEST，则基于更新策略读取所有远程仓库的元数据groupId/artifactId/maven-metadata.xml，将其与本地仓库的对应元数据合并后，计算出RELEASES或LATEST的真实值，然后基于这个值检查本地仓库和远程仓库，如步骤2和3
5. 如果依赖的版本是SNAPSHOT，则基于更新策略读取所有远程仓库的元数据groupId/artifactId/version/maven-metadata.xml，将其与本地仓库的对应元数据合并后，得到最新快照版本的值，然后基于该版本检查本地仓库，或者从远程仓库下载
6. 如果最后解析得到的构建版本是时间戳格式的快照，则复制其时间戳格式的文件至非时间戳格式，并使用该非时间戳格式的构件

### 生命周期与插件
每一个插件里包含很多功能，每一个功能就是一个插件目标

![lifecycle_plugin](/img/lifecycle_plugin.png)

![lifecycle_plugin_bind](/img/lifecycle_plugin_bind.png)

clean生命周期的各个阶段

```
pre-clean    # 执行一些清理前需要完成的工作
clean        # 清理上一次构建生成的文件
post-clean   # 执行一些清理后需要完成的工作
```

default生命周期的各个阶段

```
validate
initialize
generate-sources
process-sources        # 处理项目主资源文件，一般来说，是对src/main/resources目录的内容进行变量替换等工作后，复制到项目输出的主classpath目录中
generate-resources
process-resources
compile                # 编译项目的主源码，一般来说，是编译src/main/java目录下的java文件至项目输出的主classpath目录中
process-classes
generate-test-sources
process-test-sources   # 处理项目测试资源文件，一般来说，是对src/test/resources目录的内容进行变量替换等工作后，复制到项目输出的测试classpath目录中
generate-test-resources
process-test-resources
test-compile           # 编译项目的测试源码，一般来说，是编译src/test/java目录下的java文件至项目输出的测试classpath目录中
process-test-classes
test                  # 使用单元测试框架运行测试，测试代码不会被打包或部署
prepare-package
package               # 接收编译好的代码，打包成可发布的格式 如jar
pre-integration-test
integration-test
post-integration-test
verify
install               # 安装到本地仓库
deploy                # 发布到远程仓库
```

site生命周期的各个阶段

```
pre-site
site
post-site
site-deploy
```

### 配置文件

#### 配置文件settings.xml
settings.xml配置文件有两个，一个是全局的，位于M2_HOME/conf/settings.xml，另一个是用户级的，位于USER_HOME/.m2/settings.xml。如果两个配置文件都存在，会合并，若出现冲突，优先采用用户级别的内容。

3.0版本之后，settings.xml文件内的值可以采用${USER_HOME}这样的变量。

配置文件的内容如下:

```
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 https://maven.apache.org/xsd/settings-1.0.0.xsd">
    <localRepository>
        user.home/.m2/repository
    </localRepository>            # 本地仓库地址
    <interactiveMode>true</interactiveMode>
    <usePluginRegistry>false</usePluginRegistry> # 是否使用user.home/.m2/plugin-registry.xml
    <offline>false</offline>     # 若不能联网使用true
    <pluginGroups/>
    <servers/>                   # 服务认证信息
    <mirrors/>                   # 镜像配置
    <proxies>                    # 设置代理服务器
        <proxy>
            <id>my-proxy</id>
            <active>true</active>
            <protocol>http</protocol>
            <host>127.0.0.1</host>
            <port>8888</port>
            <!--
            <username/>
            <password/>
            <nonProxyHosts/>
            -->
        </proxy>
    </proxies>
    <profiles/>
    <activeProfiles/>
</settings>
```

##### 配置项mirrors

```
<mirror>
    <id/>
    <name/>
    <url/>
    mirrorOf>*</mirrorOf>   # 匹配所有远程仓库
</mirror>

mirrorOf取值如下:
*
external:*
repo1,repo2
*, !repo1
```

#### 配置文件pom.xml

pom.xml是每个项目的配置文件，内容如下:

```
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    
    <groupId>com.xxx</groupId>
    <artifactId>hello</artifactId>
    <version>1.0.0</version>
    <packaging>jar</packaging>      # 值为pom时是聚合，与modules配合使用
    
    <name>hello</name>
    <description>测试模板</description>
    
    <parent/>                 # 父模块
    <repositories/>           # 远程仓库配置
    <distributionManagement/> # 部署远程仓库
    <properties/>             # maven属性
    <dependencies/>
    <build/>                  # 插件绑定
    <profiles/>
    <modules/>                # 同时编译多个模块
</project>
```

#### 配置项parent

```
<parent>
    <groupId/>
    <artifactId/>
    <version/>
    <relativePath/>     # 父模块路径 优先从该目录查找，若找不到，则去本地资源库
</parent>
```

#### 配置项build

```
<build>
    <plugins>
        <plugin>
            <groupId/>
            <artifactId/>
            <version/>
            <configuration/>       # 插件配置
            <executions>
                <execution>
                <id/>
                <phase/>           # 生命周期的某个阶段
                <goals>
                    <goal/>
                </goals>           # 该阶段对应的插件目标
                <configuration/>   # 特定任务的配置
                </execution>
            <executions>
        </plugin>
    </plugins>
</build>
```

#### 配置项distributionManagement

```
<distributionManagement>
    <repository>
        <id/>             # 远程仓库id
        <name/>           # 简介
        <url/>            # 远程仓库地址
    </repository>
    <snapshotRepository>
        <id/>
        <name/>
        <url/>
    </snapshotRepository>
</distributionManagement>
```

##### 配置项repositories

```
<repositories>
    <repository>
        <id>jboss</id>
        <name>JBoss Repository</name>
        <url>http://repository.jboss.com/maven2</url>
        <releases>
            <enabled>true</enabled>
        </releases>
        <snapshots>
            <enabled>false</enabled>
        </snapshots>
        <layout>default</layout>
    </repository>
</repositories>
```

##### 配置项dependencies

```
<dependencies>
    <dependency>
        <groupId/>
        <artifactId/>
        <version/>
        <type/>                # 对应packaging
        <scope/>               # 依赖的范围
        <optional/>            #
        <exclusions>           # 排除传递性依赖，若还要使用该库，则需再声明
            <exclusion>
                <groupId/>      # 只需这两项
                <artifactId/>
            </exclusion>
        </exclusions>
    </dependency>
</dependencies>
```

##### 配置项modules

```
<modules>
    <module>xxx</module>       # 值为子模块的目录
</modules>
```