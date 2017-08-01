---
title: 理论篇-java基础
date: 2017-07-10 11:42:53
tags:
    - java
---

#### 数据类型

8种基本类型: 4种整型 2种浮点型 字符类型char(用于表示Unicode编码的字符单元) boolean类型

整型 | 存储需求 | 范围 | 特殊说明
----|---------|------|------
int | 4字节 | 20亿 |
short | 2字节 | |
long | 8字节 | | 后缀L
byte | 1字节 | |

浮点类型 | 存储需求 | 范围 | 特殊说明
-------|---------|------|--------
float | 4字节 | | 后缀F
double | 8字节 | | 后缀D

```
strictfp关键字  # 可修饰类或方法 将使用严格的浮点计算
```

char类型 表示单个字符

boolean类型: true false

数组

java中的数据没有指针运算。数组的操作使用java.util库中的Arrays。

```
int[] a;                # 仅仅是声明 并未真正创建
int[] a = new int[10];
```

#### 变量

java中不区分变量的声明与定义。

使用final关键字定义的为常量，被赋值后不能再修改。

使用static final关键字定义的为类常量。

```
C/C++中使用const关键字定义常量
```
#### 运算符

关系运算符: == != < <= > >=

逻辑运算符: && ||

位运算符: &(与) |(或) ~(非) ^(异或)

#### 字符串

java中的字符串也是不可变字符串。

字符串的比较用equals方法，千万不要使用==，因为==比较的是引用地址。

```
StringBuilder  # 非线程安全
StringBuffer   # 线程安全
```

#### 控制结构

java中有块(block)的概念。形式上就是使用一对花括号括起来的多条语句。块可以嵌套，但是不可以重复定义变量。

```
if (condition1) statement1 else if (condition2) statement2 else statement3

while (condition) statement
do statement while(condition);

for (variable : collection) statement # collection必须是数组或者实现Iterable接口的对象

switch(choice) {
    case label1: ...
    case label2: ...
    default: ...
}
case标签的取值:

* 类型为char、byte、short或int的常量表达式
* 枚举常量
* 从Java7开始，可以是字符串字面量

break [label];
continue;
```

#### 对象与类

java不支持运算符重载。

类之间的关系: 依赖(uses-a)、聚合(has-a)和继承(is-a)。

```
class ClassName {
    field1
    field2
    ...
    
    constructor1
    constructor2
    ...
    
    method1
    method2
    ...
}
```

在一个源文件中，只能有一个公有类，但可以有任意数目的非公有类。原文件名必须有公有类类名相同。

有关构造器:

* 构造器与类同名
* 每个类可以有一个以上的构造器
* 构造器可以有0个或多个参数
* 构造器没有返回值
* 构造器在new操作时被调用

提供get和set方法的好处:

* 当修改内部实现时，对外影响最小
* 可以做合法性检查

**警告:** 不要编写返回可变引用可变对象的访问器方法

**基于类的访问权限:**方法可以访问所属类的私有属性，而不仅限于访问隐式参数的私有属性。

**final关键字的用途:**

* 使用final修饰的实例域，构建对象时，必须初始化这样的域。且该域后面不能再修改。
* 使用final修饰的方法，不具备多态性
* 使用final修饰的类，不可被继承。该类中的所有方法自动成为final，属性不会。

**static关键字:**使用static修饰的属性或方法为类属性或类方法。

**方法参数:**java中采用按值传递方式。但是参数又分为两种类型: 1. 基本数据类型(数字，布尔值) 2. 对象引用

当参数是对象引用时，传递的是对象引用的副本，调用对象的方法将直接修改对象。

属性若未被初始化，则会执行默认初始化。但是局部变量必须得执行初始化。

在类定义时可以直接初始化属性。

**this关键字的用途:**

* 调用属性，比如this.xxx
* 通过this(...)调用其他构造器。

初始化块在构造器之前执行。初始化块可用static修饰，为静态初始化块，只能初始化静态属性，在类第一次加载的时候执行。

java不支持析构函数，但finalize方法保证在对象回收之前调用。但不能过多依赖该方法。

包的支持:

```
package
import
import static
```

没有public或private修饰的属性或方法具有包作用域。

类路径:

* 把类放在一个目录中
* 把JAR文件放在一个目录中
* 设置类路径，类路径是所有包含类文件的路径的集合。

javac编译器总是在当前的目录中查找文件，但java虚拟机仅在类路径中有"."目录的时候才查看当前目录。若类路径中忘记设置当前目录，则程序仍然可以编译通过，但是不能运行。

设置类路径的方法:

```
java -classpath
环境变量 CLASSPATH
```

##### 继承

extends关键字表示继承关系，java中都是公有继承。

**super关键字的用途:**

* 用来调用父类中的方法，比如super.getXXX()
* 用来调用父类的构造函数，比如super("xxx", "xxx")

若子类的构造器没有显式的调用超类的构造器，则默认调用无参构造器。若父类没有无参构造器，则编译报错。

**多态:**一个对象变量可以指示多种实际类型的现象

**动态绑定:**在运行时能够自动选择调用哪个方法的现象

**斜变**

```
class Employee {
    public Employee getBuddy() {}
}
class Manager extends Employee {
    public Manager getBuddy() {}
}

子类覆写父类的方法，且子类的返回值为父类返回值的子类型。在覆写方法时，子类的可见性不能低于父类的可见性。
```

强制类型转换:

* 只能在继承层次内进行转换
* 在讲超类转换成子类之前，应该使用instanceof进行检查

**abstract关键字:**

* 使用abstract修饰的类为抽象类，抽象类不能被实例化
* 使用abstract修饰的方法为抽象方法，包含抽象方法的类必须为抽象类

**Object类**

方法 | 解释
-----|-----
equales | 检测两个对象是否相等 |
hashCode | 对象的存储地址 一个整数值 | 
toString | 返回对象所属类名和散列码 |

**对象包装器与自动装箱**

装箱与拆箱是编译器认可的，而不是虚拟机。编译器在生成类的字节码时，插入必要的方法调用。虚拟机只是执行这些字节码。

**重要:**自动装箱规范要求boolean、byte、char<=127、介于-128到127之间的short和int被包装到固定的对象中。

**可变参数方法**

```
public static max(double ... values) {
    double largest = Double.MIN_VALUE;
    for (dboule v : values) if (v > largest) largest = v;
    return largest;
}

double m = max(3.1, 4.2, 5)
```

**枚举类**

```
public enum Size {
    SMALL(1, "S"),
    MEDIUM(2, "M"),
    LARGE(3, "L"),
    EXTRA_LARGE(4, "XL");

    private int num;
    private String des;

    Size(int num, String des) {
        this.num = num;
        this.des = des;
    }

    public String toString() {
        return des;
    }
}
```

**反射**

反射的作用:

* 在运行中分析类
* 在运行中查看对象
* 实现通用的数组操作代码
* 利用Method对象，这个对象很像C++中的函数指针

虚拟机为每个类型管理着一个Class对象，即每个类只有一个Class对象，该类的对象共享该Class对象。

重点在java.lang.reflect库。

#### 接口与内部类

* 接口中的方法自动为public
* 接口中属性自动设为public static final
* 接口中提供方法签名
* 接口中不准定义实力属性
* 接口中不准实现方法
* 接口不可以被实例化，但可以定义接口变量
* 接口可以使用instanceof关键字
* 接口可以继承

java设计者认为多继承会使语言本身变得复杂，效率也会降低。(好像是这么回事)

**对象克隆**

* 深拷贝与浅拷贝
* Cloneable接口 标记接口

**与python对比:**
python中没有私有公有属性之分，并且鼓励直接调用属性，因为有其他机制可以控制对属性的访问操作。python中也有类属性或类方法。python中也采用按值传递的方式。python中的super是一个内建函数。

python中的相等性比较:

* "==": 比较值得相等性
* "is": 比较引用地址，是否是同一个对象

python中不同类型的比较方法如下:

* 数字通过相对大小比较
* 字符串按照字典顺序，逐个字符进行比较
* 列表和元组从左到右对每部分的内容进行比较
* 字典通过排序之后的键值列表进行比较(PY3不支持)

**与C++的对比:**
C++中有值传递和引用传递两种方式。

在C++中不能直接初始化属性，所有域必须在构造器中设置。

在C++中一个构造器不能调用另一个构造器。必须将公共初始化代码抽象出来。

在C++中继承分为公有继承，保护继承和私有继承三种。

在C++中为了实现多态，需要显式的将某个方法指定为虚拟方法。