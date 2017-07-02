---
title: 理论篇-python标准库之并发执行
date: 2017-07-02 15:47:42
tags:
    - python
---

#### 线程

方法 | 用法 | 特殊说明
----|------|--------
threading.active_count() | |
threading.current_thread() | |
threading.get_ident() | | 
threading.enumerate() | | 
threading.main_thread() | |
threading.settrace(func) | |
threading.setprofile(func) | |
threading.stack_size([size]) | |
threading.TIMEOUT_MAX | |


##### Thread-Local Data

方法或类 | 用法 | 特殊说明
-------|------|-------
class threading.local | | 

```
mydata = threading.local()
mydata.x = 1
```

##### Thread Objects

创建线程的两种方法: 1. 传递一个可调用的对象给Thread 2. 继承Thread，并覆写\_\_init\_\_和run方法

方法或类 | 用法 | 特殊说明
-------|-------|--------
class threading.Thread(group=None, target=None, name=None, args=(), kwargs={}, \*, daemon=None) | |
start() | | 
run() | |
join(timeout=None) | |
name | |
setName() | |
getName() | |
ident | |
is_alive() | |
daemon | | 必须在start()调用之前设置
isDaemon() | |
setDaemon() | |

线程的几种状态如下图所示

![python_thread_1](/img/python_thread_1.png)

守护线程: 只有当守护线程退出后，整个进程才会完全退出

主线程: 程序启动时的线程

由于GIL的原因，python中的多线程是伪多线程，即同一时刻只有一个线程执行，即使在多核计算机上。

##### Lock Objects(原始锁)

原始锁是一种同步原语。原始锁有两种状态: 锁定和未锁定。当创建时，原始所处于未锁定状态，调用acquire方法时，变为锁定状态，调用release方法时，变为未锁定状态。当一个锁处于锁定状态时，其他线程调用acquire方法时将会阻塞，直到拥有该锁的线程调用release方法。如果尝试释放一个未锁定的锁，则会引发RuntimeError

锁也支持上下文管理协议，既可以使用with语句。

以下所有方法的执行都是原子的

方法或类 | 用法 | 特殊说明
-------|-------|--------
class threading.Lock | |
acquire(blocking=True, timeout=-1) | 获取锁 |
release() | 释放锁 |

##### RLock Objects(可重入锁)

可重入锁(a reentrant lock)是另一种同步原语。该锁可被同一线程获取多次。

可重入锁支持的概念: 锁定和未锁定、"owning thread" and "recursion level"。

当锁计数为0时，将锁变为未锁定状态。

方法或类 | 用法 | 特殊说明
-------|-------|--------
class threading.RLock | 创建锁 |
acquire(blocking=True, timeout=-1) | 获取锁 | 
release() | 释放锁 |

##### Condition Objects(条件变量)

条件变量和某种锁相关。创建的时候可传递，若不传递则自动创建一个RLock。

条件变量也支持上下文管理协议。使用with语句获取相应的锁。

当拥有锁的时候，可以调用其他的方法。wait方法释放锁，随后阻塞，直到其他线程通过调用notify或者notify\_all方法来唤醒它。一旦被唤醒，wait方法将重新获取该锁并返回。

notify方法唤醒一个等待的线程。notify_all方法唤醒所有的等待线程。

条件变量一般用来使用锁来同步访问一些共享的状态。


```
# consume one item
with cv:
    while not an_item_is_available():
        cv.wait()
        
    get_an_available_item()
    
# produce one item
with cv:
    make_an_item_available()
    cv.notify()
```

方法或类 | 用法 | 特殊说明
-------|-------|--------
class threading.Condition(lock=None) | |
acquire(*args) | 获取锁 |
release() | 释放锁 |
wait(timeout=None) | 等待某个条件成立 |
wait_for(predicate, timeout=None) | 等待某个条件成立 |
notify(n=1) | 唤醒一个等待的线程 |
notify_all() | 唤醒所有等待的线程 |

##### Semaphore Objects(信号量)

这是最古老的同步原语之一。一个信号量管理一个内部的计数器。该计数器通过acquire递减，通过release增加。计数器从来不会小于0。当acquire发现计数器为0时，该线程将会阻塞，直到等待另一个线程调用release。

信号量也支持上下文管理。

方法或类 | 用法 | 特殊说明
-------|-------|--------
class threading.Semaphore(value=1) | |
acquire(blocking=True, timeout=None) | |
release() | |
class threading.BoundedSemaphore(value=1) | 边界信号量 |

信号量一般用来保护某些资源，控制其最大访问并发。

##### Event Objects

这是线程之间通信的最简单的方式之一。

方法或类 | 用法 | 特殊说明
-------|-------|--------
class threading.Event | |
is_set() | |
set() | |
clear() | |
wait(timeout=None) | |

##### Timer Objects

Timer是Thread的一个子类。

方法或类 | 用法 | 特殊说明
-------|-------|--------
class threading.Timer(interval, function, args=None, kwargs=None) | |
cancel() | |

##### Barrier Objects(屏障)

这也是一种同步原语。该机制用于让指定数量的线程等待同一事件的发生，然后同时执行。

方法或类 | 用法 | 特殊说明
-------|-------|--------
class threading.Barrier(parties, action=None, timeout=None) | |
wait(timeout=None) | |
reset() | | 将barrier设置到默认状态，同时处于等待状态的线程将收到BrokenBarrierError
abort() | | 将barrier设置到broken状态，同时处于等待状态的线程将收到BrokenBarrierError
parties | |
n_waiting | |
broken | | 

#### 进程

#### 并发

#### 子进程

#### 事件调度器

#### 队列
