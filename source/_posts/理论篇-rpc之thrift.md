---
title: 理论篇-rpc之thrift
date: 2017-04-19 17:43:24
tags:
    - rpc
    - thrift
---

RPC(Remote Procedure Call Protocol)远程过程调用协议。该协议允许运行于一台计算机上的程序调用另一台计算机上的子程序，而程序员无需为这个额外的交互过程编程。

thrift是众多rpc框架中的一个。本文主要介绍下thrift。

### thrift的结构

```
服务器层: 单线程，事件驱动等
-----------------------
处理器层: 特定服务的实现
-----------------------
协议层:  json binary compact
---------------------------
传输层:  基于tcp协议或者http协议传输数据
```

#### 传输层
传输层提供了一个从网络上读写的简单抽象。有两个接口Transport和ServerTransport。

```
Transport: open close read write flush
ServerTransport: open listen accept close
```

#### 协议层
协议层定义了内存数据结构映射为线性结构的机制。简单的说就是将内存里的数据转换成可以在传输层收发的格式。比如json、xml、plain text、compact binary等

```
writeMessageBegin(name, type, seq)
writeMessageEnd()
writeStructBegin(name)
writeStructEnd()
writeFieldBegin(name, type, id)
writeFieldEnd()
writeFieldStop()
writeMapBegin(ktype, vtype, size)
writeMapEnd()
writeListBegin(etype, size)
writeListEnd()
writeSetBegin(etype, size)
writeSetEnd()
writeBool(bool)
writeByte(byte)
writeI16(i16)
writeI32(i32)
writeI64(i64)
writeDouble(double)
writeString(string)


name, type, seq = readMessageBegin()
                  readMessageEnd()
name = readStructBegin()
       readStructEnd()
name, type, id = readFieldBegin()
                 readFieldEnd()
k, v, size = readMapBegin()
             readMapEnd()
etype, size = readListBegin()
              readListEnd()
etype, size = readSetBegin()
              readSetEnd()
bool = readBool()
byte = readByte()
i16 = readI16()
i32 = readI32()
i64 = readI64()
double = readDouble()
string = readString()
```

#### 处理器层
特定的服务实现特定的处理器
```
interface TProcessor {
    bool process(TProtocol in, TProtocol out) throws TException
}
```

#### 服务器层
服务器层负责将所有功能组装起来

* 创建一个传输层
* 为传输层创建输入/输出协议
* 基于协议创建一个处理器
* 等待一个连接，然后将连接分发到处理器

### 实现

py

```
传输层:
thrift.transport.THttpClient
thrift.transport.TSocket
thrift.transport.TSSLSocket
thrift.transport.TTransport.TBufferedTransport
thrift.transport.TTransport.TFramedTransport
协议层:
thrift.protocol.TBinaryProtocol
thrift.protocol.TCompactProtocol
服务器层:
thrift.server.TServer                   # 接口
thrift.server.THttpServer               # 基于http协议的服务
thrift.server.TNonblockingServer.TNonblockingServer  #
thrift.server.TProcessPoolServer

thrift.server.TServer.TForkingServer    # 为每个请求创建一个新进程
thrift.server.TServer.TSimpleServer     # 单线程
thrift.server.TServer.TThreadPoolServer # 使用固定数量的线程池来服务请求
thrift.server.TServer.TThreadedServer   # 每个连接产生一个新的线程
```

### 参考

[测试代码](https://github.com/fenghui2013/myblog_source/tree/master/python/thrift_test)
[TThreadedServer VS TNonblockingServer](https://github.com/m1ch1/mapkeeper/wiki/TThreadedServer-vs.-TNonblockingServer)