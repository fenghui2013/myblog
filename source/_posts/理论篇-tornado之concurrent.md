---
title: 理论篇-tornado之concurrent
date: 2017-05-10 18:03:02
tags:
    - tornado
---

```
#### ioloop.py ####

class IOLoop(Configurable): pass

class PollIOLoop(IOLoop):
    def start(self):
        while True:
            event_pairs = self._impl.poll(poll_timeout)   # 1
            self._events.update(event_pairs)
            while self._events:
                fd, events = self._events.popitem()
                fd_obj, handler_func = self._handlers[fd] # 2
                handler_func(fd_obj, events)              # 3 这里执行的回调函数通过add_handler方法设置
                
                
    def add_handler(self, fd, handler, events):
        fd, obj = self.split_fd(fd)
        self._handlers[fd] = (obj, stack_context.wrap(handler))
        self._impl.register(fd, events | self.ERROR)
        
        
#### iostream.py ####

class BaseIOStream(object):
    def __init__(self, io_loop=None, max_buffer_size=None, read_chunk_size=None, max_write_buffer_size=None):
        pass
        
    def _handle_events(self, fd, events):
        # 处理读写事件, 我们只关注读事件
        if events & self.io_loop.READ:
            self._handle_read()                           # 5 对读事件进行处理
            
    def _handle_read(self):
        pos = self._read_to_buffer_loop()                 # 6 将数据从fd读到读缓冲区
        self._read_from_buffer(pos)                       # 7 从读缓冲区读取数据并调用预先设置好的回调函数
        
    def _read_from_buffer(self, pos):
        self._run_read_callback(pos, False)               # 8 运行回调函数
        
    def _run_read_callback(self, pos, streaming):
        callback = self._read_callback
        callback(*args)                                   # 9 真正执行回调函数
    
    # 解析http协议时需要用到的几种读取方法    
    def read_until_regex(self, regex, callback=None, max_bytes=None):
        future = self._set_read_callback(callback)
        
    def read_until(self, delimiter, callback=None, max_bytes=None):
        future = self._set_read_callback(callback)
        
    def read_bytes(self, num_bytes, callback=None, streaming_callback=None, partial=False):
        future = self._set_read_callback(callback)
        
    def read_until_close(self, callback=None, streaming_callback=None):
        future = self._set_read_callback(callback)
        
    def _set_read_callback(self, callback):
        self._read_callback = stack_context.wrap(callback) # 预先设置9中执行的回调函数
        
    def _add_io_state(self, state):
        self.io_loop.add_handler(self.fileno(), self._handle_events, self._state)                                              # 4 调用add_handler方法设置fd对应的handler
```

```
#### httpserver.py ####

class HTTPServer(TCPServer, Configurable, httputil.HTTPServerConnectionDelegate):
    def handle_stream(self, stream, address):
        context = _HTTPRequestContext(stream, address,
                                      self.protocol,
                                      self.trusted_downstream)
        conn = HTTP1ServerConnection( stream, self.conn_params, context)
        self._connections.add(conn)
        conn.start_serving(self)
```



```
#### web.py ####
class RequestHandler(object):
    SUPPORTED_METHODS = ("GET", "HEAD", "POST", "DELETE", "PATCH", "PUT", "OPTIONS")
    
    def head(self, *args, **kwargs):
        raise HTTPError(405)
    def get(self, *args, **kwargs):
        raise HTTPError(405)
    def post(self, *args, **kwargs):
        raise HTTPError(405)
    def delete(self, *args, **kwargs):
        raise HTTPError(405)
    def patch(self, *args, **kwargs):
        raise HTTPError(405)
    def put(self, *args, **kwargs):
        raise HTTPError(405)
    def options(self, *args, **kwargs):
        raise HTTPError(405)
    
    @gen.coroutine
    def _execute(self, transforms, *args, **kwargs):
        method = getattr(self, self.request.method.lower())
        result = method(*self.path_args, **self.path_kwargs)
        result = yield result
        
class _HandlerDelegate(httputil.HTTPMessageDelegate):
    def headers_received(self, start_line, headers):
        pass
        
    def def data_received(self, data):
        pass
        
    def finish(self):
        self.request.body = b''.join(self.chunks)
        self.request._parse_body()
        self.execute()
        
    def execute(self):
        self.handler = self.handler_class(self.application, self.request, **self.handler_kwargs)
        self.handler._execute(transforms, *self.path_args, **self.path_kwargs)
```

```
#### http1connection.py ####

class HTTP1Connection(httputil.HTTPConnection):

    def read_response(self, delegate):
        return self._read_message(delegate)
        
    # 解析http协议
    @gen.coroutine
    def _read_message(self, delegate):
        # 读取header body等
        self.stream.read_until_regex()
        header_future = delegate.headers_received(start_line, headers)
        elegate.finish()
        
class HTTP1ServerConnection(object):

    def start_serving(self, delegate):
        self._serving_future = self._server_request_loop(delegate)
        self.stream.io_loop.add_future(self._serving_future,
                                       lambda f: f.result())
                                       
    @gen.coroutine
    def _server_request_loop(self, delegate):
        try:
            while True:
                conn = HTTP1Connection(self.stream, False, self.params, self.context)
                request_delegate = delegate.start_request(self, conn)
                ret = yield conn.read_response(request_delegate)
                if not ret:
                    return
                yield gen.moment
        finally:
            delegate.on_close(self)
```