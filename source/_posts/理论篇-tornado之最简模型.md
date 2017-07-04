---
title: 理论篇-tornado之最简模型
date: 2017-07-04 12:36:27
tags:
    - tornado
---

tornado是以事件和协程为基础的服务器。由于python中并未实现真正的协程，所以使用生成器实现协程的功能。

以下代码是tornado框架的核心，读懂了该代码，对tornado框架也应该就清楚了。

```
import random
import time

def odd_f():
    count = 0
    while True:
        count += 1
        num = yield 'continue'
        print("odd: {}".format(num))
        if count >= 10:
            break
    yield 'quit'

def even_f():
    count = 0
    while True:
        count += 1
        num = yield 'continue'
        print("even: {}".format(num))
        if count >= 10:
            break
    yield 'quit'


def main():
    _callbacks = {}
    _callbacks["odd"] = odd_f()
    _callbacks["odd"].next()
    _callbacks["even"] = even_f()
    _callbacks["even"].next()

    while True:
        time.sleep(1)
        n = random.randint(0, 1000000)
        keys = _callbacks.keys()
        if n & 1:
            if "odd" in keys:
                res = _callbacks["odd"].send(n)
                if res == "quit":
                    del _callbacks["odd"]
        else:
            if "even" in keys:
                res = _callbacks["even"].send(n)
                if res == "quit":
                    del _callbacks["even"]

        if len(_callbacks) == 0:
            break


if __name__ == "__main__":
    main()
```
