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

位运算符: &(与) |(或) ~(非) ^(异或) <<(左移，使用符号位填充) >>(右移) >>>(右移，使用0填充)

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
* 应用于局部变量，实例变量和静态变量。在定义final变量时，不必进行初始化，调用时被初始化一次，如果执行多次调用，则创建多个变量。

**static关键字:**

* 使用static修饰的属性或方法为类属性或类方法。
* 使用static修饰的内部类没有指向外围类对象的引用

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
* 在将超类转换成子类之前，应该使用instanceof进行检查

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

**接口与回调**

在面向过程的编程语言(比如C)中，通常使用函数实现回调机制。但在像java这种纯面向对象的编程语言中，也可以通过传递Method对象，但由于使用复杂，速度和安全性问题，所以使用接口来实现回调机制。

接口中定义需要被回调的方法，实现回调机制的类实现接口中的方法，然后传递对象。这些接口一般称为标记接口

**内部类**

内部类是定义在另一个类中的类。

使用内部类的原因如下:

* 内部类方法可以访问该类定义所在的作用域中的数据，包括私有的数据
* 内部类可以对同一个包中其他类不可见
* 当想要定义一个回调函数且不想编写大量代码时，使用匿名内部类比较便捷

**匿名内部类**

```
# 实现超类的匿名类
new SuperType(construction parameters) {
    inner class methods and data
}

# 实现接口的匿名类
new InterfaceType() {
    methods and data
}
```

**静态内部类**

使用staitc修饰的内部类为静态内部类，静态内部类没有指向外围类的引用。


#### 应用程序的部署

##### JAR文件

一个jar文件既可以包含类文件，也可以包含图像和声音这些其他类型的文件。jar文件使用zip压缩格式进行压缩。

jar文件中还包含一个清单文件MANIFEST.MF

```
Manifest-Version: 1.0

Sealed: true          # 密封包

Name: Woozle.class

Name: com/mycompany/mypkg/

Main-Class: com.mycompany.mypkg.MainAppClass  # 程序的入口点
                                      # 最后一行必须以换行符结束
```


#### 异常机制

* java中所有的异常都继承自Throwable类
* Throwable类有两个子类，一个是Error，一个是Exception。Error属于系统内部错误或资源耗尽错误。Exception为最常见的异常
* Exception下有分为两类: RuntimeException和IOException

RuntimeException有如下几种:

* 错误的类型转换
* 数组访问越界
* 访问空指针

unchecked exceptions 和 checked exceptions

**断言**

```
assert condition;
assert condition: expression;

# 启动断言
java -enableassertions MyApp
java -ea:MyClass MyApp


# 禁用断言
java -disableassertions MyApp
java -da:MyClass MyApp
```

#### 泛型程序设计？

泛型使程序具有更好的可读性和安全性。

通配符类型(wildcard type)

泛型类

```
public class Pair<T, U> {
    private T first;
    private U second;
    
    public Pair() {first=null; second=null;}
    public Pair(T first, U second) {
        this.first = first;
        this.second = second;
    }
    
    public T getFirst() {return first}
    public U getSecond() {return second}
    
    public void setFirst(T first) {
        this.first = first;
    }
    
    public void setSecond(U second) {
        this.second = second;
    }
}
```

泛型方法

```
class ArrayAlg {
    public static <T> T getMiddle(T ... a) {
        return a[a.length/2];
    }
}
```

类型变量的限定

```
<T extends BoundingType1 &BoudingType2>  # 表明T应该是绑定类型的子类型
限定类型可以是接口也可以是类。接口可以多个，类只能有一个，且必须在限定列表中的第一个
```

对虚拟机来说不存在泛型之说，所有的类都是普通类。

无论何时定义一个泛型类型，都自动提供了一个相应的原始类型。原始类型通过将类型变量替换为限定类型来获得。若类型变量是一个无限定的变量，则直接用Object类替换。若类型变量是一个有限定的变量，则用第一个限定的类型变量来替换。

翻译泛型表达式时编译器插入强制类型转换

翻译泛型方法时会使用桥方法(bridge method)的技巧。其中桥方法的技巧在斜变中也被应用到。

```
为了提高效率应该将标签接口(即没有方法的接口)放在边界列表的末尾。
```

关于泛型的tips:

* 虚拟机中没有泛型，只有普通的类和方法
* 所有的类型参数都用它们的限定类型替换
* 桥方法被合成来保持多态
* 为保持类型安全性，必要时插入强制类型转换


###### 约束与限制

* 不能用基本类型实例化类型参数


#### 集合？

* 接口与实现分离
* Abstract开头的类是为扩展类库准备的

使用的基础数据结构有: 数组、链表、哈希表、堆、红黑树

集合 | 类 | 数据结构
----|-----|-------
List | ArrayList | 数组
List | LinkedList | 链表
Set | HashSet | 哈希表
Set | TreeSet | 红黑树
Set | LinkedHashSet | 哈希表 链表
Map | HashMap | 哈希表 对key进行哈希
Map | TreeMap | 红黑树 对key进行排序
Map | LinkedHashMap | 哈希表 链表
Queue | ArrayDeque | 循环数组
Queue | PriorityQueue | 堆

**集合框架的接口**

```
        Iterable
           |
       Collection                Map        Iterable    RandomAccess
           |                      |            |
  -------------------             |            |
  |        |        |             |            |
 List     Set     Queue       SortedMap   ListIterable
           |         |            |
       SortedSet  Deque      NavigableMap
           |
      NavigableSet
```

**集合框架中的类**

```
         AbstractCollection
                 |
   ---------------------------------------------
   |                 |             |           |
AbstractList     AbstractSet  AbstractQueue    |                      AbstractMap
   |                 |             |           |                           |
 ---------------  --------         |           |                      -----------
   |           |  |      |         |           |                      |         |
Abstract       |HashSet TreeSet PriorityQueue ArrayDequeue          HashMap  TreeMap
SequentialList |
   |           |
LinkedList ArrayList
```

视图与包装器？？？


#### 线程

创建一个线程的方法:

* 创建一个类并实现Runnable接口中的run方法
* 创建一个类对象，使用该对象创建一个Thread对象
* 调用Thread对象的start方法

**线程状态**

```
New --> Runnable --> Blocked/Waiting/Timed waiting --> Terminated

New: new Thread(r)
Runnable: start()  可运行的线程可能处于运行状态也可能没有运行
Blocked: 当一个线程试图获取一个内部的对象锁(而不是java.util.concurrent库中的锁)，而该锁被其它线程持有，该线程进入阻塞状态
Waiting: 当线程等待另一个线程通知调度器一个条件时，它自己进入等待状态。在调用Object.wait方法或Thread.join方法，或者是等待java.util.concurrent库中的Lock或Condition时，就会出现这种情况。
Timed waiting: 调用带有超时参数的方法导致线程进入计时等待状态。
Terminated: 正常或异常退出。
```

**线程优先级**

当虚拟机依赖于宿主机平台的线程实现机制时，java线程的优先级被映射到宿主机平台的优先级上，优先级个数也许更多，也许更少。比如Windows有7个线程优先级，而Linux没有线程优先级。

**守护线程**

当只剩下守护线程的时候，虚拟机就退出了。所以，守护线程不应该访问固有资源，如文件，数据库等，因为他们会在任何时候发生中断。


**线程同步**

java里面提供了两种同步机制: 1. synchronized关键字 2. ReentrantLock和Condition类

可重入锁指的是拥有某个锁的线程可以再次拥有该锁。该机制通过计数器实现。

Lock和Condition:

* 锁用来保护代码片段，任何时刻只能有一个线程执行被保护的代码
* 锁可以管理试图进入被保护代码段的线程
* 锁可以拥有一个或多个相关的条件对象(即条件变量)
* 每个条件对象管理那些已经进入被保护的代码段但还不能运行的线程

```
# Lock
lock()
unlock()

# Condition
await()
signalAll()
signal()
```

synchronized关键字是java语言实现的一种内部机制: 每个对象都有一个内部锁。

```
await()
notify()
notifyAll()
```

```
//synchronized
public synchronized void method() {
    method body
}

// ReentrantLock
myLock = new ReentrantLock();
myLock.lock()
try {
    critical section;
} finally {
    myLock.unlock();
}
```


**同步阻塞**

同步阻塞更像是一种显式利用对象锁的方式。

```
Object obj = new Object()
synchronized (obj) {
    critical section;
}
```

**监视器**

监视器是一种解决方案，该方案的目标是在程序员不考虑锁的情况下，也能保证多线程的安全性。

监视器必须满足如下特性:

* 监视器是只包含私有域的类
* 每个监视器类的对象有一个相关的锁
* 使用该锁对所有的方法进行加锁
* 该锁可以有任意多个相关条件

**java实现了不严格的监视器。**

**volatile域**

使用锁机制的开销很大，有时候仅仅为了访问一个或两个实例域，就没必要使用锁，所以出现了volatile域，该关键字为实例域的同步访问提供了一种免锁机制。

造成不同步的根源:

* 多处理器的计算机能够暂时在寄存器或本地内存缓冲区中保存内存中的值。结果是，运行在不同处理器上的线程可能在同一个内存位置取到不同的值
* 编译器可以改变指令执行的顺序以使吞吐量最大化。这种顺序上的变化不会改变代码语义，但是编译器假定内存的值仅仅在代码中有显式的修改指令时才会改变。然而，内存的值可以被另一个线程改变

使用锁的情况下，不用考虑以上问题。详见(java内存模型和线程规范 JSR133)


如果声明一个域为volatile，那么编译器和虚拟机就知道该域是可能被另一个线程并发更新的。**但该关键字并不提供原子性，只对变量的赋值和访问起作用。**

**final变量**

```
final Map<String, Double> accounts = new HashMap();
```

其他线程会在构造函数完成构造之后才看到这个accounts变量。


**死锁**
死锁产生的条件: 1. 由于逻辑错误导致 2. 由于并发工具使用错误导致(比如notify())


**线程本地数据**

ThreadLocal

**锁测试与超时**

在尝试获取一个锁或等待某个条件时，可以加一个等待时间。该机制可以避免由于并发工具使用错误导致的死锁的发生。


**读写锁**

```
private ReentrantReadWriteLock rwl = new ReentrantReadWriteLock();
private Lock readLock = rwl.readLock();
private Lock writeLock = rwl.writeLock();

public double getTotalBalance() {
    readLock.lock();
    try {}
    finally {
        readLock.unlock();
    }
}

public void transfer() {
    writeLock.lock();
    try {}
    finally {
        writeLock.unlock();
    }
}
```

**阻塞队列**

使用底层的锁机制有很大的灵活性，但是也带来了一定的复杂性。所以，java提供了阻塞队列，程序员不需要关心底层的锁机制，就可以实现多线程的管理。


**并发安全的集合**

java也提供了一些线程安全的数据结构。在java.util.concurrent包中。

```
ConcurrentHashMap
ConcurrentSkipListMap
ConcurrentSkipListSet
ConcurrentLinkedQueue
CopyOnWriteArrayList
CopyOnWriteArraySet
```

**同步包装器**

java提供的大部分集合不是线程安全的，但是可以通过同步包装器将其变为线程安全的。

```
List<E> synchArrayList = Collections.synchronizedList(new ArrayList<E>());

对于该集合的迭代，需要使用客户端锁定

synchronized(synchArrayList) {
    迭代代码;
}
```

**Callable和Future**

**线程池**

使用线程池的步骤:

* 调用Executors类中的静态的方法newCachedThreadPool或其他方法
* 调用submit提交Runnable或Callable对象
* 如果想要取消一个任务，或如果提交Callable对象，那就要保存好返回的Future对象
* 当不再提交任何任务时，调用shutdown

**控制任务组**



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