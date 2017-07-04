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

multiprocessing是一个支持产生进程的包，该包的api与threading类似。多进程不受GIL的限制，可以充分利用多核资源。

方法或类 | 用法 | 特殊说明
-------|-------|--------
multiprocessing.active_children() | |
multiprocessing.cpu_count() | |
multiprocessing.current_process() | |
multiprocessing.freeze_support() | |
multiprocessing.get_all_start_methods() | |
multiprocessing.get_context(method=None) | |
multiprocessing.get_start_method(allow_none=False) | |
multiprocessing.set_executable() | |
multiprocessing.set_start_method(method) | |


##### Process Class

在multiprocessing里，进程通过创建Process对象产生，随后调用start方法。

方法或类 | 用法 | 特殊说明
-------|-------|--------
class multiprocessing.Process(group=None, target=None, name=None, args=(), kwargs={}, *, daemon=None) | |
run() | |
start() | | 父进程调用
join([timeout]) | | 父进程调用
name | |
is_alive() | | 父进程调用
daemon | |
pid | |
exitcode | | 父进程调用
authkey | |
sentinel | |
terminate() | | 父进程调用

```
from multiprocessing import Process
import time

def f(name):
    time.sleep(10)
    print('hello', name)

if __name__ == "__main__":
    p = Process(target=f, args=('bob',))
    p.start()
    p.join()
```

##### Contexts and start methods

根据平台的不同，multiprocessing支持三种不同的开始方法。这些开始方法是:

* spawn

    父进程开始一个全新的python解释器。子进程只继承与运行run方法相关的资源。该方法相对于下面两种是慢的。
    在Unix和Windows上均可用，在Windows上是默认的。
* fork

    父进程使用os.fork()来创建python解释器。开始的时候，子进程和父进程是一样的。所有的资源被子进程继承。安全的创建一个多线程的进程的子进程是有问题的。
    仅在Unix上可用。在Unix上是默认的。
* forkserver

    该方法会创建一个服务器进程，专门用来创建子进程。

使用set\_start\_method()方法可用来选择开始方法。该方法仅被使用一次。

```
import multiprocessing as mp

def foo(q):
    q.put('hello')

if __name__ == '__main__':
    mp.set_start_method('spawn')
    q = mp.Queue()
    p = mp.Process(target=foo, args=(q,))
    p.start()
    print(q.get())
    p.join()
```

##### 进程之间通信

multiprocessing支持两种类型的进程间通信。

方法或类 | 用法 | 特殊说明
-------|-------|--------
multiprocessing.Pipe([duplex]) | |
class multiprocessing.Queue([maxsize]) | |
qsize() | |
empty() | |
full() | |
put(obj[, block[, timeout]]) | |
put_nowait(obj) | |
get([block[, timeout]]) | |
get_nowait() | |
close() | |
join_thread() | |
cancel_join_thread() | |

方法或类 | 用法 | 特殊说明
-------|-------|--------
class multiprocessing.SimpleQueue | |
empty() | |
get() | |
put(item) | |

方法或类 | 用法 | 特殊说明
-------|-------|--------
class multiprocessing.JoinableQueue([maxsize]) | |
task_done() | |
join() | |

* Queue

    Queue类是线程和进程安全的。
    
    ```
    from multiprocessing import Process, Queue

    def f(q):
        q.put([42, None, 'hello'])

    if __name__ == '__main__':
        q = Queue()
        p = Process(target=f, args=(q,))
        p.start()
        print(q.get())    # prints "[42, None, 'hello']"
        p.join()
    ```
* Pipes
    
    Pipe()函数返回一对被管道连接的连接对象。
    
    ```
    from multiprocessing import Process, Pipe

    def f(conn):
        conn.send("hello world")
        conn.close()

    if __name__ == "__main__":
        parent_conn, child_conn = Pipe()
        p = Process(target=f, args=(child_conn,))
        p.start()
        print(parent_conn.recv())
        p.join()
    ```   

##### 进程之间同步

multiprocessing包含了所有来自threading的同步原语。

方法或类 | 用法 | 特殊说明
-------|-------|--------
class multiprocessing.Barrier(parties[, action[, timeout]]) | |
class multiprocessing.BoundedSemaphore([value]) | |
class multiprocessing.Condition([lock]) | |
class multiprocessing.Event | |
class multiprocessing.Lock | |
acquire(block=True, timeout=None) | |
release() | |
class multiprocessing.RLock | |
acquire(block=True, timeout=None) | |
release() | |
class multiprocessing.Semaphore([value]) | |



```
from multiprocessing import Process, Lock

def foo(l, i):
    time.sleep(random.randint(1, 5))
    l.acquire()
    try:
        print("hello, {}".format(i))
    finally:
        l.release()


if __name__ == "__main__":
    lock = Lock()

    for num in range(10):
        Process(target=foo, args=(lock, num,)).start()
```

##### 进程之间共享

方法或类 | 用法 | 特殊说明
-------|-------|--------
multiprocessing.Value(typecode_or_type, \*args, lock=True) | |
multiprocessing.Array(typecode_or_type, size_or_initializer, \*, lock=True) | |

* 共享内存

    python提供了两种共享内存组件: Value和Array
    
    ```
    from multiprocessing import Process, Value, Array

    def f(n, a):
        n.value = 3.1415927
        for i in range(len(a)):
            a[i] = -a[i]

    if __name__ == '__main__':
        num = Value('d', 0.0)
        arr = Array('i', range(10))

        p = Process(target=f, args=(num, arr))
        p.start()
        p.join()

        print(num.value)
        print(arr[:])
    ```

* 服务进程

##### 进程池

Pool类代表了进程池。该类提供了几种不同的分配任务的方式。

方法或类 | 用法 | 特殊说明
-------|-------|--------
class multiprocessing.pool.Pool([processes[, initializer[, initargs[, maxtasksperchild[, context]]]]]) | |
apply(func[, args[, kwds]]) | 同步执行任务 |
apply_async(func[, args[, kwds[, callback[, error_callback]]]]) | 异步执行任务 |
map(func, iterable[, chunksize]) | |
map_async(func, iterable[, chunksize[, callback[, error_callback]]]) | |
imap(func, iterable[, chunksize]) | |
imap_unordered(func, iterable[, chunksize]) | |
starmap(func, iterable[, chunksize]) | |
starmap_async(func, iterable[, chunksize[, callback[, error_back]]]) | |
close() | |
terminate() | |
join() | |

方法或类 | 用法 | 特殊说明
-------|-------|--------
class multiprocessing.pool.AsyncResult | |
get([timeout]) | |
wait([timeout]) | |
ready() | |
successful() | |

```
from multiprocessing import Pool, TimeoutError
import time
import os

def f(x):
    return x*x

if __name__ == "__main__":
    with Pool(processes=4) as pool:
        print(pool.map(f, range(10)))
        for i in pool.imap_unordered(f, range(10)):
            print(i)

        res = pool.apply_async(f, (20,))
        print(res.get(timeout=1))

        res = pool.apply_async(os.getpid, ())
        print(res.get(timeout=1))

        multiple_results = [pool.apply_async(os.getpid, ()) for i in range(4)]
        print([res.get(timeout=1) for res in multiple_results])

        res = pool.apply_async(time.sleep, (10, ))
        try:
            res.get(timeout=1)
        except TimeoutError:
            print("TimeoutError")

        print('xxx')

    print('end')
```

##### 日志

方法或类 | 用法 | 特殊说明
-------|-------|--------
multiprocessing.get_logger() | |
multiprocessing.log_to_stderr() | |

#### 并发

异步执行可以使用多线程或者是多进程。

方法或类 | 用法 | 特殊说明
-------|-------|--------
class concurrent.futures.Executor | 抽象类 |
submit(fn, \*args, \*\*kwargs) | 返回一个Future对象 |
map(func, *iterables, timeout=None, chunksize=1) | |
shutdown(wait=True) | |

##### ThreadPoolExecutor

ThreadPoolExecutor是Executor的子类，使用线程池来执行异步调用。

方法或类 | 用法 | 特殊说明
-------|-------|--------
class concurrent.futures.ThreadPoolExecutor(max_workers=None) | |

##### ProcessPoolExecutor

ProcessPoolExecutor是Executor的子类，使用进程池来执行异步调用。

方法或类 | 用法 | 特殊说明
-------|-------|--------
class concurrent.futures.ProcessPoolExecutor(max_workers=None) | |

##### Future Objects

方法或类 | 用法 | 特殊说明
-------|-------|--------
class concurrent.futures.Future | |
cancel() | |
cancelled() | |
running() | |
done() | |
result(timeout=None) | |
exception(timeout=None) | |
add_done_callback(fn) | |
concurrent.futures.wait(fs, timeout=None, return_when=ALL_COMPLETED) | |
concurrent.futures.as_completed(fs, timeout=None) | |


并发的威力:

```
import concurrent.futures
import time

def f(num):
    time.sleep(5)
    print(num)
    return "----{}".format(num)


def process_main():
    with concurrent.futures.ProcessPoolExecutor(max_workers=20) as executor:
        for res in executor.map(f, range(10)):
            print(res)

def thread_main():
    with concurrent.futures.ThreadPoolExecutor(max_workers=20) as executor:
        for res in executor.map(f, range(10)):
            print(res)

def main2():
    for res in map(f, range(10)):
        print(res)

if __name__ == "__main__":
    start = time.time()
    thread_main()
    end = time.time()
    print(end-start)
```

#### 子进程

#### 事件调度器

#### 队列
