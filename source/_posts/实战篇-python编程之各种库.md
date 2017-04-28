---
title: 实战篇-python编程之各种库
date: 2017-04-20 11:59:12
tags:
    - python
---

### glob

功能: 查找符合特定规则的文件路径名
使用: 利用简单的正则符号匹配文件

```
*    # 匹配0个或多个字符
?    # 匹配1个字符
[]   # 匹配指定范围内的字符 比如[0-9]

glob.glob("*.xxx") # 返回以xxx结尾的文件组成的列表
glob.iglob("*.xxx") # 返回迭代器
```


### 数据库相关

#### MySQLdb

```
import MySQLdb

conn = MySQLdb.connect(host='',user='',passwd='',db='',port=5002)
cur = conn.cursor()

# insert
# delete
# update
cur.execute("update ...")
conn.commit()

# query
cur.execute("select ...")
for doc in cur:
    pass
    
# 事务
conn.commit()
conn.rollback()  # 回滚到上次commit

try:
    cur = conn.cursor()
    cur.execute("xxx1")
    cur.execute("xxx2")
    cur.close()
    conn.commit()
except Exception, e:
    cur.close()
    conn.rollback()
```