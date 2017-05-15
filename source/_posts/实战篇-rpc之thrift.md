---
title: 实战篇-rpc之thrift
date: 2017-04-20 11:19:58
tags:
    - rpc
---

### 安装

```
yum install thrift
```

### 使用

#### 编写idl文件
shared.thrift

```
namespace java shared
namespace php shared

struct SharedStruct {
    1: i32 key,
    2: string value
}

service SharedService {
    SharedStruct getStruct(1: i32 key)
}
```

tutorial.thrift

```
include "shared.thrift"

namespace java tutorial
namespace php tutorial

typedef i32 MyInteger

const i32 INT32CONSTANT = 9853
const map<string, string> MAPCONSTANT = {'hello':'world'}

enum Operation {
    ADD = 1,
    SUB,
    MUL,
    DIV
}

struct Work {
    1: i32 num1 = 0,
    2: i32 num2,
    3: Operation op,
    4: optional string comment
}

exception InvalidOperation {
    1: i32 whatOp,
    2: string why
}

service Calculator extends shared.SharedService {
    void ping(),
    i32 add(1:i32 num1, 2:i32 num2),
    i32 calculate(1:i32 logid, 2:Work w) throws (1:InvalidOperation ouch),
    oneway void sub(1:i32 num1, 2:i32 num2)
}
```

#### 生成特定语言的包

```
thrift -r -gen py tutorial.thrift
```