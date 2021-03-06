---
title: 理论篇-高性能网络IO模型
date: 2017-06-09 13:58:06
tags:
    - 架构
---

#### C10K问题

C10K问题指的是让一台服务器支持1万个并发连接的问题。由于早期的服务器模型基于多进程(或多线程)。当一个新连接到达时，创建一个新的进程(或线程)来处理该连接。当服务器服务一万个连接的时候，就需要创建一万个进程(或线程)。服务器创建进程(或线程)是需要系统开销的，比如创建进程需要占用更多的内存，进程间切换需要占用更多的cpu。而在当时一台服务器同时创建一万个进程(或线程)是不可能实现(**随着计算机硬件的升级，现在不知道可不可以，有时间测试下**)。于是，C10K问题在当时就是一个很难解决的问题。

#### IO多路复用技术

IO多路复用技术，这个名词给人的第一感觉是很难懂。我们拆开来一点点的分析: IO，大家都知道，输入输出。多路指的是什么呢？什么是路呢？如果我们把一个tcp连接当做一路的话，那么多路也就不难理解了，多路指的是多个tcp连接。复用，从字面上很好理解，就是重复利用的意思。现在整体理解如下:就是让多个tcp连接重复利用输入输出的技术。

我们再举一个例子: 比如在一家餐馆，这家餐馆的老板很精明，懂IO多路复用技术，所以只雇了一个服务员，这个服务员负责记下每位客人的菜单，然后将菜单送到厨房，让厨师开始烧菜。当菜烧好之后，服务员再负责将菜送到相应的客人面前，让客人用餐。其中每个客人相当于一个tcp连接。服务员是什么呢？

支持IO多路复用技术的操作系统都做了相应的实现。比如linux中epoll，unix中的kqueue，windows中的iocp等。现在有了答案，服务员就相当于这些实现。

#### 两种高性能网络IO模型

有了IO多路复用技术，C10K问题就不攻自破了。我们只需要一个单进程单线程的服务，就能处理大量的并发连接请求。就像一个服务员可以同时服务很多客人一样。

目前，利用IO多路复用技术实现高性能网络IO的有两种模型: reactor和proactor。我们还是以服务员的例子来说明。

**reactor模式:**
 
1. 服务员收集目前所有未点餐客人的用餐需求，
2. 将菜单送到厨房，等待厨师做好后
3. 将菜一一送到相应的客人面前，再回到1

**proactor模式:** 

1. 服务员收集目前所有未点餐客人的用餐需求和是否有菜做好
2. 将菜单送到厨房(等到厨师做好菜之后，会通知服务员过来上菜)，若有菜做好则执行3否则再回到1
3. 服务员将菜送到客人面前，再回到1

因为reactor模式比较简单，所以实际中用的比较多。但是如果餐馆的生意非常火，一个服务员肯定是忙不过来的，所以即使是reactor模式也有很多种不同的实现方法。

首先，我们先对服务器需要处理的任务进行建模。

* 当新连接到达时，有接收新连接的任务，acceptor
* 当连接上有数据到达时，有读数据的任务，read
* 对读取的数据进行处理，包括解码，业务处理，编码，我们统称为compute
* 将计算结果发送给客户端，send

##### 单进程单线程reactor模型

服务器有一个进程并且该进程只有一个线程，该线程负责所有的任务。如下图所示:

![io_model_1](/img/io_model_1.png)

**点评:**该模型实现简单，性能也不差。但有很明显的缺点: 1. 不能高效得利用多核cpu。2. 如果计算占用过多的cpu，会导致大量的连接处于等待状态，新的连接也不能建立。

#### 单进程多线程reactor模型

服务器有一个进程，但是该进程有多个线程，主线程负责acceptor、read和send任务。其他线程负责compute任务。

![io_model_2](/img/io_model_2.png)

**点评:**该模型实现相对简单，而且能高效的利用多核服务器的优势。并且也避免了第一种模型的两个缺点。

#### 多进程的reactor模型

多进程的reactor模型也有多种: 1. 每个进程负责所有的任务(未完待续)

也有很多其它变种的实现，这些实现想达到的目的就是有效的利用多核。

(未完待续)