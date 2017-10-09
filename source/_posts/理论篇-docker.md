---
title: 理论篇-docker
date: 2017-09-03 10:24:32
tags:
    - 虚拟化技术
---

docker的主要目标: **Build, Ship and Run any App, Anywhere**

### 虚拟化技术与Docker

#### Linux Container(LXC)

Linux Container是一种内核虚拟化技术，可以提供轻量级的虚拟化，以便隔离进程和资源，而且不需要提供指令解释机制以及全虚拟化的其他复杂性。与传统虚拟化技术相比，优势如下:

* 与宿主机使用同一个内核，性能损耗小
* 不需要指令集模拟
* 不需要即时编译
* 容器可以在CPU核心的本地运行指令，不需要任何专门的解释机制
* 避免了准虚拟化和系统调用替换中的复杂性
* 轻量级隔离，在隔离的同时还提供共享机制，以实现容器和宿主机的资源共享

但是，使用的复杂性限制了它的普及。

#### Docker

Docker在LXC基础上进一步优化了容器的使用体验，使这一技术得到了普及。Docker提供了各种容器管理工具(如分发、版本、移植等)让用户无需关注底层的操作，可以简单明了的管理和使用容器。

##### Docker在开发和运维中的优势

* 更快速的交付和部署，一次开发，处处部署。
* 更高效的资源利用，无其他虚拟化管理程序的开销
* 更轻松的迁移和扩展，任何支持docker的系统上都可以运行容器
* 更简单的更新管理，Dockerfile

##### 和传统虚拟化技术的比较

* Docker容器很快，启动和停止可以在秒级实现，这相比传统的虚拟机方式要快得多
* Docker容器对系统资源需求很少，一台主机上可以同时运行数千个Docker容器
* Docker通过类似git的操作来方便用户获取、分发和更新应用镜像，指令简明，学习成本低
* Docker通过Dockerfile配置文件来支持灵活的自动化创建和部署机制，提高工作效率

#### 虚拟化与Docker

虚拟化技术是一个通用概念。在计算领域，一般指的是计算虚拟化或通常说的服务器虚拟化。

>维基百科: 在计算机技术中，虚拟化是一种资源管理技术，是将计算机的各种实体资源，如服务器、网络、内存及存储等予以抽象、转换后呈现出来，打破实体结构间的不可分割的障碍，使用户可以用比原本的组态更好的方式来应用这些资源。

虚拟化可分为基于硬件的虚拟化和基于软件的虚拟化。后者又可分为基于应用的虚拟化和基于平台的虚拟化(通常意义的虚拟化)。基于平台的虚拟化又有如下分类:

* 完全虚拟化 虚拟机模拟完整的底层硬件环境和特权指令的执行过程，客户操作系统无需进行修改。例如VMware Workstation、VirtualBox、QEMU等
* 硬件辅助虚拟化 利用硬件(主要是CPU)辅助支持(目前x86体系结构上可用的硬件辅助虚拟化技术包括Intel-TV和AMD-V)处理敏感指令来实现完全虚拟化的功能。客户操作系统无需修改。例如VMware Workstation、Xen、KVM。
* 部分虚拟化 只针对部分硬件资源进行虚拟化，客户操作系统需要进行修改。
* 超虚拟化 部分硬件接口以软件的形式提供给客户操作系统，客户操作系统需要进行修改，例如早期的Xen
* 操作系统级虚拟化 内核通过创建多个虚拟的操作系统实例(内核和库)来隔离不同的进程。容器相关技术即在这个范畴

### Docker相关

docker有三个核心概念: 镜像(image)、容器(container)和仓库(repository)

#### 镜像相关

docker镜像类似于虚拟机镜像，可以理解为一个面向docker引擎的只读模板，包含了文件系统。镜像是创建docker容器的基础。通过版本管理和增量的文件系统，docker提供了一套十分简单的机制来创建和更新现有的镜像。

镜像文件一般由若干层组成。层(Layer)是AUFS(Advanced Union File System)中的重要概念，是实现增量保存与更新的基础。

```
docker pull NAME[:TAG]  # 拉取镜像 若不显式指定TAG，则默认会选择latest标签
docker images           # 查看本地镜像
docker inspect          # 查看镜像信息
docker search           # 搜索镜像
docker rmi [OPTIONS] IMAGE [IMAGE...] # IMAGE可以是tag或ID 当为tag且tag不唯一时，只删除tag 当为ID时 首先删除所有的tag 然后删除镜像文件
```

**镜像删除注意事项**

* IMAGE可以是tag或ID
* 为tag且tag不唯一时，只删除该tag
* 为tag且tag唯一时，删除镜像文件
* 为ID时，删除所有的tag，然后删除镜像文件
* 当该镜像有容器运行时，默认是不能删除的，若要删除 需加-f进行强制删除

##### 创建镜像

创建镜像有三种方法:

* 基于已有镜像的容器创建
* 基于本地模板导入
* 基于Dockerfile创建

**基于已有镜像的容器创建**

```
docker commit [OPTIONS] CONTAINER [REPOSITORY[:TAG]] # 创建镜像
```

**基于本地模板导入**

推荐使用OpenVZ提供的模板来创建

```
```

[模板地址](https://download.openvz.org/template/precreated/)

**使用dockerfile创建镜像**

dockerfile由一行行命令语句组成，且支持以#开头的注释。

```
# Author: wangbiao
# Command format: Instruction [arguments/command] ...
# 第一行必须指定基于的基础镜像
FROM ubuntu

# 维护者信息
MAINTAINER wangbiao 841824090@qq.com

# 镜像的操作指令
RUN apt-get update && apt-get install -y nginx  # 在当前镜像基础上添加新的一层并提交为新的镜像

# 容器启动时执行指令
CMD /usr/sbin/nginx
```

**指令**

* FROM
    
    第一条指令必须是FROM。若在同一个dockerfile中创建多个镜像时可使用多次。
    
    ```
    FROM <image>
    FROM <image>:<tag>
    ```
* MAINTAINER

    维护者信息
    
    ```
    MAINTAINER <name>
    ```
* RUN

    在当前镜像基础上执行指令，并提交为新的镜像。可使用\换行
    
    ```
    RUN <command>
    RUN ["executable", "param1", "param2"]
    ```
* CMD

    指定容器启动时执行的命令，每个Dockerfile只能有一条CMD命令。如果执行了多条命令，只有最后一条会被执行。如果用户启动容器的时候指定了运行的命令，则会覆盖掉CMD指定的命令。
    
    ```
    CMD ["executable", "param1", "param2"] # 使用exec执行
    CMD command param1 param2    # 在/bin/sh中执行，需要交互时使用
    CMD ["param1", "param2"]     # 提供给ENTRYPOINT的默认参数
    ```
* EXPOSE

    指定docker容器暴露的端口号，供互联系统使用。启动容器时，使用-P参数时，docker会自动分配一个端口转发到指定的端口。使用-p参数时，指定具体映射端口。
    
    ```
    EXPOSE <port> [<port>...]
    ```
* ENV

    指定一个环境变量，会被后续RUN指令使用，并在容器运行时保持。
    
    ```
    ENV <key> <value>
    ```
* ADD

    复制指定的<src>到容器中的<dest>。其中<src>可以是Dockerfile所在目录的一个相对路径(文件或目录)；也可以是一个URL；还可以是一个tar文件(自动解压为目录)。
    
    ```
    ADD <src> <dest>
    ```
* COPY

    复制本地主机的<src>(为Dockerfile所在目录的相对路径，文件或目录)为容器中的<dest>。目标目录不存在时，会自动创建。当使用本地目录为源目录时，推荐使用COPY
    
    ```
    COPY <src> <dest>
    ```
* ENTRYPOINT

    配置容器启动后执行的命令，且不可被docker run提供的参数覆盖。每个Dockerfile只能有一个ENTRYPOINT，当指定多个时，只有最后一个生效。
    
    ```
    ENTRYPOINT ["executable", "param1", "param2"]
    ENTRYPOINT command param1 param2(shell中执行)
    ```
* VOLUME

    创建一个可以从本地主机或其他容器挂载的挂载点，一般用来存放数据库和需要保存的数据等
    
    ```
    VOLUME ["/data"]
    ```
* USER

    指定运行容器时的用户名或UID，后续的RUN也会使用指定用户。当服务不需要管理员权限时，可以通过该命令指定运行用户。
    
    ```
    USER daemon
    ```
* WORKDIR

    为后续的RUN，CMD，ENTRYPOINT指令配置工作目录。可以使用多个WORKDIR指定，后续命令如果参数是相对的，则会基于之前命令指定路径。
    
    ```
    WORKDIR /path/to/workdir
    ```
* ONBUILD

    配置当所创建的镜像作为其他新创建镜像的基础镜像时，所执行的操作指令。使用该指令的镜像，推荐在tag中注明。
    
    ```
    ONBUILD [INSTRUCTION]
    ```
    
**创建镜像**

该命令读取指定路径下的Dockerfile，并将该路径下所有内容发送给服务端，由服务端来创建镜像。因此一般建议放置Dockerfile的目录为空。可使用.dockerignore文件来让docker忽略路径下的目录和文件。

```
docker build
```

**存出和载入镜像**

```
docker save -o ubuntu_14.04.tar ubuntu:14.04  # 存出
docker load --input ubuntu_14.04.tar          # 载入
or
docker load < ubuntu_14.04.tar
```

#### 容器相关

docker容器类似一个轻量级的沙箱，docker利用容器来运行和隔离应用。镜像自身是只读的，容器从镜像启动的时候，docker会在镜像的最上层创建一个可写层，镜像本身将保持不变。

```
docker create    # 从镜像创建容器，此时容器未执行
docker start     # 启动已存在的容器
docker restart   # 重启已存在的容器
docker run       # 运行一个停止状态的容器
docker stop      # 停止容器
docker rm        # 删除容器
docker ps -a     # 查看容器
# 进入后台运行的容器
docker attach    #
docker exec      # 可以执行其他命令 比如重开一个shell
# 导入和导出 容器迁移时可用
docker export    # 导出
docker import    # 导入
```

利用docker run来创建并启动容器时，docker会进行如下操作:

1. 检查本地是否存在指定的镜像，不存在就从公有仓库下载
2. 利用镜像创建并启动一个容器
3. 分配一个文件系统，并在只读的镜像层外面挂载一层可读写层
4. 从宿主机配置的网桥接口中桥接一个虚拟接口到容器中去
5. 从地址池中配置一个IP地址给容器
6. 执行用户指定的应用程序
7. 执行完毕后容器被终止

当应用退出后，容器随即退出(因为容器是为运行应用而存在的)。

**容器是用来区分应用的**

**停止容器注意事项**

* 首先向容器发送SIGTERM信号
* 等待一段时间(默认10s)后，再发送SIGKILL信号终止容器

#### 仓库相关

docker仓库类似与代码仓库，是docker集中存放镜像文件的场所。

可以使用公有仓库也可以搭建自己的私有仓库。

#### 认证相关

首先需要登录registry，才能提交镜像文件。

```
docker login       # 登录
docker logout      # 登出
```

#### 数据管理

容器中管理数据主要有两种方式:

* 数据卷(data volumes)
* 数据卷容器(data volume containers)


##### 数据卷

数据卷是一个可供容器使用的特殊目录，它绕过文件系统，可以提供很多有用的特性:

* 数据卷可以在容器之间共享和重用
* 对数据卷的修改会立马生效
* 对数据卷的更新，不会影响镜像
* 卷会一直存在，直到没有容器使用

```
docker run -v         # 创建数据卷
```


##### 数据卷容器

本质是启动一个普通的容器，并创建一个数据卷，其他容器可以使用该容器的数据卷。

```
docker run --volumes-from  # 带有数据卷容器启动
```

#### 网络基础配置

docker目前提供了映射容器端口到宿主主机和容器互联机制来为容器提供网络服务。

##### 端口映射实现访问容器

**注意事项**

* -P，docker会随机映射一个49000~49900的端口至容器内部开放的网络端口
* -p，指定要映射的端口，可用的格式:
    
    ```
    ip:hostPort:containerPort  
    ip::containerPort
    hostPort:containerPort   # 默认会绑定本地所有接口上的所有地址
    ```

```
docker port      # 查看端口配置
```

##### 容器互联实现容器间通信

容器的连接系统是除了端口映射外另一种可以与容器中应用进行交互的方式。它会在源和接收容器之间创建一个隧道，接收容器可以看到源容器指定的信息。

```
docker run --link name:alias  # 容器连接
```

docker通过两种方式为容器公开连接信息:

* 环境变量
* 更新/etc/hosts文件


**两个值得深究的技术:** SDN(软件定义网络) NFV(网络功能虚拟化)