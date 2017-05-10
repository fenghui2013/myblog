---
title: 理论篇-tornado之httpserver
date: 2017-05-10 09:50:07
tags:
    - tornado
---

一个非阻塞的单线程的HTTP服务器。


#### 数据结构

```
class HTTPServer(TcpServer, Configurable, httputil.HTTPServerConnectionDelegate):
    def __init__(self, *args, **kwargs):
        pass
        
    def initialize(
        self,
        request_callback,
        no_keep_alive=False,
        io_loop=None,
        xheaders=False,
        ssl_options=None,
        protocol=None,
        decompress_request=False,
        chunk_size=None,
        max_header_size=None,
        idle_connection_timeout=None,
        body_timeout=None,
        max_body_size=None,
        max_buffer_size=None,
        trusted_downstream=None):
        self.request_callback = request_callback
        self.no_keep_alive = no_keep_alive
        self.xheaders = xheaders
        self.protocol = protocol
        self.conn_params = HTTP1ConnectionParameters(
            decompress = decompress_request,
            chunk_size = chunk_size,
            max_header_size = max_header_size,
            header_timeout=idle_connection_timeout or 3600,
            max_body_size = max_body_size,
            body_timeout = body_timeout,
            no_keep_alive = no_keep_alive
        )
        TCPServer.__init__(
            self,
            io_loop = io_loop,
            ssl_options = ssl_options,
            max_buffer_size = max_buffer_size,
            read_chunk_size = chunk_size
        )
        self._connections = set()
        self.trusted_downstream = trsuted_downstream
```
