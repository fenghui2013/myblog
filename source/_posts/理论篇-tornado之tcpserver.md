---
title: 理论篇-tornado之tcpserver
date: 2017-05-09 20:18:19
tags:
    - tornado
---

#### 数据结构
```
class TCPServer(object):
    def __init__(self, io_loop=None, ssl_options=None, max_buffer_size=None, read_chunk_size=None):
        self.io_loop = io_loop
        self.ssl_options = ssl_options
        self._sockets = {} # fd->socket object
        self._pending_sockets = []
        self._started = False
        self._stoped = False
        self.max_buffer_size = max_buffer_size
        self.read_chunk_size = read_chunk_size
```

#### 提供的方法

方法| 功能 | 特别说明
---|------|-------
listen(port, address='')|
add_sockets(sockets)|
add_socket(socket)|
bind(port, address=None, family=<AddressFamily.AF_UNSPEC:0>, backlog=128, reuse_port=False)|
start(num_processs=1)|
stop()|
**handle_stream(stream, address)**| 处理某一连接上的新的IO流 | 该方法需要子类实现

TCPServer有以下几种初始化方式

1. listen: 简单的单进程
    
    ```
    server = TCPServer()
    server.listen(8888)
    IOLoop.current().start()
    ```
2. bind/start: 简单的多进程
    
    ```
    server = TCPServer()
    server.bind(8888)
    server.start(0)         # fork processes
    IOLoop.current().start()
    ```
3. add_sockets: 高级的多进程

    ```
    sockets = bind_socket(8888)
    tornado.process.fork_processes(0)  # fork processes
    server = TCPServer()
    server.add_sockets(sockets)
    IOLoop.current().start()
    ```
    
    
#### 使用

```
from tornado.tcpserver import TCPServer
from tornado.iostream import StreamClosedError
from tornado import gen

class EchoServer(TCPServer):
    @gen.coroutine
    def handle_stream(self, stream, address):
        while True:
            try:
                data = yield stream.read_until(b"\n")
                yield stream.write(data)
            except StreamClosedError:
                break
```