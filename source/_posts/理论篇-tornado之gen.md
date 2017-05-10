---
title: 理论篇-tornado之gen
date: 2017-05-10 14:09:40
tags:
    - tornado
---

tornado.gen是一个基于生成器的接口，使开发在异步环境下更加容易。简单点说就是，该包是一个协程的实现。

仔细对比如下两段代码

```
class AsyncHandler(RequestHandler):
    @asynchronous
    def get(self):
        http_client = AsynchHTTPClient()
        http_client.fetch("http://example.com", callback=self.on_fetch)
        
    def on_fetch(self, response):
        do_something_with_response(response)
        self.render("template.html")
        
class GenAsyncHandler(RequestHandler):
    @gen.coroutine
    def get(self):
        http_client = AsyncHTTPClient()
        response = yield http_client.fetch("http://example.com")
        do_something_with_response(response)
        self.render("template.html")
    
    @gen.coroutine
    def get(self):
        http_client = AsyncHTTPClient()
        response1, response2 = yield [http_client.fetch(url1),
                                        http_client.fetch(url2)]
        response_dict = yield dict(response3=http_client.fetch(url3),
                                    response4=http_client.fetch(url4))
                                    
        response3 = response_dict['response3']
        response4 = response_dict['response4']
```

#### 提供的接口

接口 | 功能 | 特殊说明
----|------|-------
coroutine(func, replace_callback=True)| 异步生成器的装饰器 | 
engine(func)| 基于回调的异步生成器的装饰器 | 
Return(value=None)| 特殊的异常，从coroutine中返回一个值 |
with_timeout(timeout, future, io_loop=None, quiet_exceptions=())| 为future设置超时时间 |
exception TimeoutError | 
sleep(duration) | 非阻塞的睡眠 |
monent | 允许被yield的一个特殊对象，为了让IOLoop执行一个迭代
WaitIterator(\*args, \*\*kwargs) | 
multi(children, quiet_exceptions=()) | 允许多个异步操作并行执行
multi_future(children, quite_exception=()) |
Task(func, \*args, \*\*kwargs) | 调整一个基于回调的异步函数，为了在协程中使用 |
class Arguments|
covert_yielded(yielded) | 将一个yield对象转换为Future
maybe_future(x) | 转换x为Future |
is_coroutine_function(func) | 检测函数是否是协程函数


#### 预备知识
在看tornado代码之前，先了解下python里的生成器是怎么样的。

```
def f():
    count = 0
    while True:
        res = yield count, "xxx"
        print(res)
        if res == "quit":
            break
        count += 1
    yield "quit"


g = f()

print(g.next())
print(g.send("xxx"))
print(g.send("xxx"))
print(g.send("quit"))
```

#### 源码分析

```
def coroutine(func, replace_callback=True):
    return _make_coroutine_wrapper(func, replace_callback=True)

_futures_to_runners = weakref.WeakKeyDictionary()

def _make_coroutine_wrapper(func, replace_callback):
    ...
    wrapped = func
    @functools.wraps(wrapped)
    def wrapper(*args, **kwargs):
        ...
        try:
            result = func(*args, **kwargs)    # 执行被包装的函数, 返回一个生成器result
        except (Return, StopIteration) as e:
            result = _value_from_stopiteration(e)
        except Exception:
            future.set_exc_info(sys.exc_info())
            return future
        else:
            if (result, GeneratorType):
                try:
                    ...
                    yielded = next(result)
                    ...
                except (StopIteration, Return) as e:
                    future.set_result(_value_from_stopiteration(e))
                except Exception:
                    future.set_exc_info(sys.exc_info())
                else:
                    _futures_to_runners[future] = Runner(result, future, yielded)   # 将生成器result传入Runner
                yielded = None
                try:
                    return future
                finally:
                    future = None
        future.set_result(result)
        return future
    ...
    return wrapper
```

看下Runner

```    
class Runner(object):
    def __init__(self, gen, result_future, first_yielded):
        self.gen = gen
        self.result_future = result_future
        self.future = _null_future
        self.yield_point = None
        self.pending_callbacks = None
        self.results = None
        self.running = False
        self.finished = False
        self.had_exception = False
        self.io_loop = IOLoop.current()
        self.stack_context_deactivate = None
        if self.handle_yield(first_yielded):
            gen = result_future = first_yielded = None
            self.run()
            
    def run(self):
        # starts or resumes the generator, running until it reaches a yield point that is not ready.
        if self.running or self.finished:
            return
        try:
            self.running = True
            while True:
                future = self.future
                if not future.done:
                    return
                self.future = None
                try:
                    orig_stack_contexts = stack_context._state.contexts
                    exc_info = None
                    
                    try:
                        value = future.result()
                    except Exception:
                        self.had_exception = True
                        exc_info = sys.exc_info()
                    future = None
                    
                    if exc_info is not None:
                        try:
                            yielded = self.gen.throw(*exc_info)
                        finally:
                            exc_info = None
                    else:
                        yielded = self.gen.send(value)   # 重点, resume生成器
                    ...
                except (StopIteration, Return) as e:
                    ...
                    return
                except Exception:
                    ...
                    return
                if not self.handle_yield(yielded):
                    return
                yielded = None
        finally:
            self.running = False
            
    def handle_yield(self, yielded):
        pass
```