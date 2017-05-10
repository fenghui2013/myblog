---
title: 理论篇-tornado之概览
date: 2017-05-09 19:37:58
tags:
    - tornado
---

### 异步和非阻塞IO
实时的web功能需要每个用户与服务器保持一个长连接，对于服务器来说，大部分连接是处于空转状态的。传统的同步模式的web服务器需要使用一个线程来服务一个连接。

为了最小化并发连接的数量，tornado使用了一个单线程的事件循环。这对编程来说是一个很大的挑战，需要让所有的操作保持异步和非阻塞。因为同一时间只能有一个操作执行，若该操作阻塞，其他操作也将被阻塞，整个服务处于不可用状态。

异步与非阻塞是相关的，但是不是一个事情。现实中，这两个概念经常被混用，下面我们区分一下。

#### 阻塞
当一个函数返回之前一直再等待一些事情的发生我们就说该函数被阻塞了。一般用来描述操作系统提供的接口，比如read write等


#### 异步
一个函数在完成之前就返回，通常会在触发后续操作之前在后台执行一些其他操作。这个概念不好理解，我们举个例子。比如发起一个网络请求，同步模式下，该函数发起一个请求，然后一直等待，直到返回结果，然后对结果进行处理，返回给调用者。异步模式下，该函数发起一个请求，并注册一个回调函数，然后返回，等请求返回结果的时候，会自动触发回调函数的执行。异步需要一些底层机制的支持才能实现。一般用来描述完成一件事的两种不用的方式。

实现异步接口的方式有如下几种:

* 回调参数
* 返回一个占位符
* 发送到队列
* 回调注册(比如POSIX signals)

如果还是不明白，仔细体会下面的代码:

```
# 同步模式
from tornado.httpclient import HTTPClient

def synchronous_fetch(url):
    http_client = HTTPClient()
    response = http_client.fetch(url)
    return response.body
    
# 异步模式
from tornado.httpclient import AsyncHTTPClient

def asynchronous_fetch(url):
    http_client = AsynchHTTPClient()
    def handle_response(response):
        callback(response.body)
    http_client.fetch(url, callback=handler_response)
    
# 使用协程实现的以写同步代码的方式实现异步
from tornado.concurrent import Future

def async_fetch_future(url):
    http_client = AsyncHTTPClient()
    my_future = Future()
    fetch_future = http_client.fetch(url)
    fetch_future.add_done_callback(
        lambda f: my_future.set_result(f.result())
    )
    return my_future
    
from tornado import gen

@gen.coroutine
def fetch_coroutine(url):
    http_client = AysnchHTTPClient()
    response = yield http_client.fetch(url)
    raise gen.Return(response.body)
```
**备注**:"raise gen.Return(response.body)"是python2的一个特有实现。原因是在python2里生成器不允许返回值，为了让生成器返回值，tornado的协程触发一个叫做Return的异常，协程捕获到该异常后，将其作为一个返回值。在3.3之后，"return response.body"获得同样的结果。

### 协程
协程使用python里的yield关键字来挂起和恢复执行序列，从而替代了回调链。协程像同步代码一样简单，并且不像线程代价巨大(比如上下文切换)。

#### python3.5新特性: async和await


### 框架

#### 异步网络

* tornado.ioloop 主要的事件循环
* tornado.iostream 读写接口的封装
* tornado.netutil 网络相关工具
* tornado.tcpclient tcp客户端
* tornado.tcpserver tcp服务器

#### HTTP服务器和客户端

* tornado.httpserver 非阻塞的HTTP服务器
* tornado.httpclient 阻塞的HTTP客户端
* tornado.httputil 操作HTTP headers和urls
* tornado.http1connection HTTP/1.x 客户端和服务器实现

#### 协程和并发

* tornado.gen 简化异步代码
* tornado.concurrent 使用threads和futures工作
* tornado.locks 同步原语
* tornado.queues 协程队列
* tornado.process 多进程工具