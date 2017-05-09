---
title: 理论篇-tornado之ioloop
date: 2017-05-09 17:26:43
tags:
    - tornado
---

tornado.ioloop是tornado的主事件循环。

#### IOLoop提供的接口

接口|功能|特别说明
---|---|---
static current()|返回当前线程的IOLoop实例
make_current()|将当前IOLoop实例标记为当前线程的
static instance()|创建并返回一个新的IOLoop实例|使用了线程锁,防止并发
static initialized()|检查实例是否被创建
install()|安装IOLoop实例为单例|在IOLoop的子类里使用
static clear_instance()|清除全局的IOLoop实例
start()|开始事件循环|未实现
stop()|停止事件循环|未实现
run_sync(func, timeout=None)|运行一个给定的函数|
close(all_fds=False)|关闭IOLoop, 释放所有的资源|
add_handler(fd, handler, events)|注册接收fd事件的处理器|未实现
update_handler(fd, events)|改变fd的监听事件|未实现
remove_handler(fd)|停止监听fd的事件|未实现
add_callback()||


```
class IOLoop():
    _instance_lock = threading.Lock()
    _current = threading.local()
    
    @staticmethod
    def instance():
        if not hasattr(IOLoop, "_instance"):
            with IOLoop._instance_lock:
                if not hasattr(IOLoop, "_instance"):
                    IOLoop.__instance = IOLoop()
        return IOLoop._instance
```