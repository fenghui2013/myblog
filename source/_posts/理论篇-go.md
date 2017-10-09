---
title: 理论篇-go
date: 2017-09-12 19:39:55
tags:
    - go
---

CSP(communicating sequential processes)

go 有i++ 没有--i，且i++是一个语句，不能被赋值，例如a = i++

go的格式要求非常严格。

go只有一种循环结构for

变量声明的几种方式

```
s := ""        # 仅被使用在函数里
var s string # 默认初始化为""
var s = ""     # 该种方式不常用 除了声明多值时
var s string = "xxx"   # 给定初始化值
```

go提供指针，但不提供指针运算。


#### program structure

##### Names

25 keywords

```
break     default       func   interface select
case      defer         go     map       struct
chan      else          goto   package   switch
const     fallthrough   if     range     type
continue  for           import return    var
```

```
Constants: true false iota nil
Types: int int8 int16 int32 int64
       uint uint8 uint16 uint32 uint64 uintptr
       float32 float64 complex128 complex64
       bool byte rune string error
Functions: make len cap new append copy close delete
           complex real imag
           panic recover
```

函数内定义的变量，作用域为函数。函数外定义的变量，作用域为包内的所有文件。以大写字母开头的变量名，其作用域为整个程序。小写字母开头的变量名，其作用域为包。go中更喜欢驼峰风格。

##### Declarations

```
four declarations: var const type func
```

##### Variables

```
var name type = expression
```

**Short Variable Declarations:**within a function, an alternate form called short variable declaration may be used to declare and initialize local variables.

```
name := expression
```

```
i, j = 0, 1  # declaration
i, j = j, i  # assignment
```

短变量声明中不一定都是新的变量，如果其中的变量之前已经声明过，则仅仅是简单的赋值。若所有的变量都被声明过，则会报错。

##### Pointers

```
var x int
var y *int
y := &x
```

##### the new function

The expression new(T) creates an unnamed variable of type T, initializes it to the zero value of T, and return its address, which is a value of type *T.

```
p := new(int)
fmt.Println(*p)
```

##### lifetime of variables

全局变量的生命周期是整个程序运行期间，局部变量的生命周期是局部调用期间。不可达的变量将会被垃圾回收器回收。

编译器根据具体情况在堆上或者栈上申请变量内存。

##### Assignments

**tuple assignments**

##### Assignability

##### Type Declarations

新定义一种类型。类似C语言中的typedef

```
type name underlying-type
```

##### Packages and Files

每个源文件可以有个init函数，当程序执行时，init函数会按照声明的顺序自动被调用。初始化顺序为:自底向上，main包是最后一个。

```
func init() {
}
```

##### scope

scope is a compile-time property. lifetime is a run-time property.

```
全局作用域 本地作用域
本地作用域可以覆盖全局的
搜索变量时先本地后全局，若都找到，则报未定义错误
```

#### Basic Data Types

go提供了四种类型策略: 基本类型、组合类型、引用类型和接口类型。

基本类型包括数字、字符串和布尔值。组合数据类型包括数组和结构体。引用类型包括指针、切片、字典、函数和channel。接口类型后续再介绍。

go的数字类型包含几种大小不同的整型、浮点型和复杂的数据

```
int8 int16 int32 int64
uint8 uint16 uint32 uint64
rune == int32
byte == uint8
uintptr  # 大小不定，存储指针值 一般底层编程使用
```

int和uint是在特定平台上最高效的大小。具体大小视平台而定。


```
float32  float64
complex64  complex128
```

##### 字符串

字符串是一个不可变的字节序列。

内建函数len返回的是字节的数量。index操作(s[i])返回的是第i个字节。

```
```


#### 复合数据类型

```
var q [3]int = [3]int{1, 2, 3}   # 数组及初始化
s := []int{0, 1, 2, 3, 4, 5}

make([]T, len)   # 创建一个指定元素类型、长度和容量的slice，此时容量等于长度
make([]T, len, cap)  #

append           # 向slice中追加元素

ages := make(map[string]int)    # map

ages := map[string]int{
    "a": 1,
    "b": 2
}
equals
ages := make(map[string]int)
ages["a"] = 1
ages["b"] = 2

delete(ages, "a")       # delete 
_ = &ages["a"]          # 禁止对map元素取址的原因是重新分配后之前的地址可能无效
```