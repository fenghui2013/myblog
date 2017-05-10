---
title: 理论篇-tornado之iostream
date: 2017-05-09 20:52:50
tags:
    - tornado
---

#### BaseIOStream

##### 数据结构

```
class BaseIOStream(object):
    def __init__(self, io_loop=None, max_buffer_size=None, read_chunk_size=None, max_write_buffer_size=None):
        self.io_loop = io_loop or ioloop.IOLoop.current()
        self.max_buffer_size = max_buffer_size or 104857600 #100MB
        self.read_chunk_size = min(read_chunk_size or 65536, self.max_buffer_size // 2)
        self.max_write_buffer_size = max_write_buffer_size
        self.error = None
        self.read_buffer = bytearray()
        self._read_buffer_pos = 0
        self._read_buffer_size = 0       # 已经读取的数据的大小
        self._write_buffer = bytearray()
        self._write_buffer_pos = 0
        self._write_buffer_size = 0
        self._write_buffer_frozen = False
        self._total_write_index = 0
        self._total_write_done_index = 0
        self._pending_writes_while_frozen = []
        self._read_delimiter = None
        self._read_regex = None
        self._read_max_bytes = None
        self._read_bytes = None
        self._read_partial = False
        self._read_until_close = False
        self._read_callback = None
        self._read_future = None
        self._streaming_callback = None
        self._write_callback = None
        self._write_futures = collections.deque()
        self._close_callback = None
        self._connect_callback = None
        self._connect_future = None
        self._connecting = False
        self._state = None
        self._pending_callbacks = 0
        self._closed = False
```

##### 接口

接口| 功能 | 特别说明
---|------|--------
write(data, callback=None)|
read\_bytes(num_bytes, callback=None, streaming_callback=None, partial=False)|
read\_util(delimiter, callback=None, max_bytes=None)|
read\_until\_regex(regex, callback=None, max_bytes=None)|
read\_until\_close(callback=None, streaming_callback=None)|
close(exc_info=False)|
set\_close\_callback(callback)|
closed()|
reading()|
writing()|
set\_nodelay()|
fileno()|
close\_fd()|
write\_to\_fd(data)|
read\_from\_fd()|
get\_fd\_error()|

#### IOStream
socket的读写接口

##### 数据结构

```
class IOStream(BaseIOStream):
    def __init__(self, socket, *args, **kargs):
        self.socket = socket
        self.socket.setblocking(False)
        super(IOStream, self).__init__(*args, **kargs)
```

##### 接口

接口| 功能 | 特别说明
----|-----|--------
connect(address, callback=None, server_hostname=None)|

#### SSLIOStream
#### PipeIOStream