---
title: 理论篇-peewee
date: 2017-07-04 18:38:01
tags:
    - python
---

ORM框架的理论基础:

python | mysql
-------|------
Model class | Database table
Field instance | Column on a table
Model instance | Row in a database table


```
import logging
from datetime import date
import time

from peewee import *

logger = logging.getLogger("peewee")
logger.setLevel(logging.DEBUG)
logger.addHandler(logging.StreamHandler())

db = MySQLDatabase('peewee_test', host='192.168.99.110', port=3306, user='root', passwd='xxx', charset='utf8')

class BaseModel(Model):
    class Meta:
        database = db

class Person(BaseModel):
    name = CharField(max_length=10, null=False, index=True)
    birthday = DateField(null=False, default=None)
    is_relative = BooleanField()

class Pet(BaseModel):
    owner = ForeignKeyField(Person, related_name='pets')
    name = CharField()
    animal_type = CharField()


db.connect()
# ---- create table ----
db.create_tables([Person, Pet])

# ---- save ----
bob = Person(name='Bob', birthday=date(1989, 4, 17))
bob.save()


foo = Person.create(name='Foo', birthday=date(1991, 1, 6))
time.sleep(30)
foo.name = 'Fu'
foo.save()

# ---- save and delete ----
test = Person.create(name="test", birthday=date(2017, 1, 1))
time.sleep(30)
test.delete_instance()


uncle_bob = Person.create(name='Bob', birthday=date(1960, 1, 15), is_relative=True)
grandma = Person.create(name='Grandma', birthday=date(1935, 3, 1), is_relative=True)
herb = Person.create(name='Herb', birthday=date(1950, 5, 5), is_relative=False)


bob_kitty = Pet.create(owner=uncle_bob, name='Kitty', animal_type='cat')
herb_fido = Pet.create(owner=herb, name='Fido', animal_type='dog')
herb_mittens = Pet.create(owner=herb, name='Mittens', animal_type='cat')
herb_mittens_jr = Pet.create(owner=herb, name='Mittens Jr', animal_type='cat')

# ---- select ----
fu = Person.select().where(Person.name == 'Fu').get()
print(fu.birthday)
bob = Person.get(Person.name == 'Bob')
print(bob.birthday)

for person in Person.select():
    print(person.name, person.birthday)


for person in Person.select().order_by(Person.name):
    print(person.name, person.birthday)


for person in Person.select().order_by(Person.birthday.desc()):
    print(person.name, person.birthday)


for person in Person.select():
    print(person.name, person.pets.count(), 'pets')
    for pet in person.pets:
        print('    ', pet.name, pet.animal_type)


subquery = Pet.select(fn.COUNT(Pet.id)).where(Pet.owner == Person.id)
query = (Person.select(Person, Pet, subquery.alias('pet_count')).join(Pet, JOIN.LEFT_OUTER).order_by(Person.name))

for person in query.aggregate_rows():
    print(person.name, person.pet_count, 'pets')
    for pet in person.pets:
        print('    ', pet.name, pet.animal_type)


db.close()
```

#### 管理你的数据库

##### 多线程应用

peewee将连接存储到线程的本地数据上，因此每个线程持有一个数据库连接。如果你想自己管理连接，可以在初始化数据库的时候加上参数threadlocals=False

##### 运行时数据库配置

有时候数据的配置直到运行时才知道，因为这些值可能从配置文件中加载。此种情况下，使用如下代码:

```
database = SqliteDatabase(None)  # Un-initialized database.

class SomeModel(Model):
    class Meta:
        database = database

database.init(database_name, host='localhost', user='postgres')
```

##### 动态的定义一个数据库

多个数据库使用一个数据模型的场景下，使用Proxy

```
database_proxy = Proxy()  # Create a proxy for our db.

class BaseModel(Model):
    class Meta:
        database = database_proxy  # Use proxy for our DB.

class User(BaseModel):
    username = CharField()

# Based on configuration, use a different database.
if app.config['DEBUG']:
    database = SqliteDatabase('local.db')
elif app.config['TESTING']:
    database = SqliteDatabase(':memory:')
else:
    database = PostgresqlDatabase('mega_production_db')

# Configure our proxy to use the db we specified in config.
database_proxy.initialize(database)
```

##### 连接池

在web应用中，为了提高程序的性能，必须使用连接池。连接池提供了如下两个功能:

* 连接超时时间设置
* 最大连接数


```
db = PooledMySQLDatabase(
    'peewee_test',
    max_connections=4,
    stale_timeout=300,
    host='127.0.0.1',
    port=3306,
    user='root',
    passwd='xxx',
    charset='utf8'
)
```

##### 从从节点读

为了提高数据库的性能，写入主库，但是从从库中读取。

```
from peewee import *
from playhouse.read_slave import ReadSlaveModel

# Declare a master and two read-replicas.
master = PostgresqlDatabase('master')
replica_1 = PostgresqlDatabase('replica', host='192.168.1.2')
replica_2 = PostgresqlDatabase('replica', host='192.168.1.3')

class BaseModel(ReadSlaveModel):
    class Meta:
        database = master
        read_slaves = (replica_1, replica_2)

class User(BaseModel):
    username = CharField()
```

##### 模式修改

```
from playhouse.migrate import *

my_db = SqliteDatabase('my_database.db')
migrator = SqliteMigrator(my_db)

title_field = CharField(default='')
status_field = IntegerField(null=True)

with my_db.transaction():
    migrate(
        migrator.add_column('some_table', 'title', title_field),
        migrator.add_column('some_table', 'status', status_field),
        migrator.drop_column('some_table', 'old_column'),
    )
```

##### 从已存在的数据库中创建模型

使用pwiz库

##### 增加请求钩子

该方法不推荐使用，因为效率极低。

###### tornado

```
from tornado.web import RequestHandler

db = SqliteDatabase('my_db.db')

class PeeweeRequestHandler(RequestHandler):
    def prepare(self):
        db.connect()
        return super(PeeweeRequestHandler, self).prepare()

    def on_finish(self):
        if not db.is_closed():
            db.close()
        return super(PeeweeRequestHandler, self).on_finish()
```

##### 高级连接管理

```
with db.execution_context() as ctx:
    # A new connection will be opened or, if using a connection pool,
    # pulled from the pool of available connections. Additionally, a
    # transaction will be started.
    user = User.create(username='charlie')

# When the block ends, the transaction will be committed and the connection
# will be closed (or returned to the pool).

@db.execution_context(with_transaction=False)
def do_something(foo, bar):
    # When this function is called, a separate connection is made and will
    # be closed when the function returns.
```

##### 使用多个数据库

使用Using语句

```
master = PostgresqlDatabase('master')
read_replica = PostgresqlDatabase('replica')

class Data(Model):
    value = IntegerField()

    class Meta:
        database = master

# By default all queries go to the master, since that is what
# is defined on our model.
for i in range(10):
    Data.create(value=i)

# But what if we want to explicitly use the read replica?
with Using(read_replica, [Data]):
    # Query is executed against the read replica.
    Data.get(Data.value == 5)

    # Since we did not specify this model in the list of overrides
    # it will use whatever database it was defined with.
    SomeOtherModel.get(SomeOtherModel.field == 3)
```

##### 自动重连

```
from peewee import *
from playhouse.shortcuts import RetryOperationalError


class MyRetryDB(RetryOperationalError, MySQLDatabase):
    pass


db = MyRetryDB('my_app')
```

##### 记录查询

```
# Print all queries to stderr.
import logging
logger = logging.getLogger('peewee')
logger.setLevel(logging.DEBUG)
logger.addHandler(logging.StreamHandler())
```

##### 增加其他数据库驱动

目前peewee支持Postgres, MySQL and SQLite，但也可以手动添加其他数据库的支持。

### 模型与字段

