---
title: 理论篇-java编程之spring
date: 2017-04-16 10:49:07
tags:
    - java
    - spring
---

记得第一次接触java是在2010年，当时在读大二，当时只是学习java的基础语法。由于那时候对网络等知识的欠缺再加上java web的复杂性，所以一直也没弄明白java web开发到底是什么东西。

### 前置知识
java世界中，还有一个很明显的特点，就是专业术语特别的多，很容易让新学者摸不着头脑。下面就将学习过程中遇到的专业术语尽可能简单的介绍给大家。

javabean简单的说就是只拥有属性及其对应的get set方法的java类。

pojo(plain old java object)就是指简单的javabean，为了避免与EJB混淆所创造的简称。

EJB(enterprise javabean)是一个用来构筑企业级应用的服务器端可被管理组件。个人理解就是实现了服务器端一些通用功能的java类。spring就是用来代替EJB的。

### spring
spring是一个模块化的框架。spring的本质是依赖注入(dependency injection, DI)和面向切面编程(aspect-oriented programming, AOP)。

spring的核心理念:

* 基于pojo的轻量级和最小侵入性编程
* 通过依赖注入和面向接口编程实现松耦合
* 基于切面和惯例实现声明式编程
* 通过切面和模板减少样板式代码

>侵入编程指的是在使用某些框架时，在写业务代码的时候需要继承框架的某些类以利用框架的某些功能。

#### DI
写代码的时候，我们一直在追求低耦合高内聚。没有耦合的代码意味着一点关系也没有，如果需要多个类配合完成一个任务时肯定是不行的。如果耦合过高，代码将难扩展难测试。spring是如何解决低耦合问题的呢？

>创建应用组件之间协作的行为称为装配(wiring)。

spring装配应用组件的方式有三种。

* 在xml中进行显式配置
* 在java中进行显式配置
* 隐式的bean发现机制(组件扫描(component scanning))和自动装配

当使用第三方组件时，需要通过java或xml显式的配置。

通过xml文件如下:

```
<?xml version="1.0" encoding="UTF-8">
<beans>
    <bean id="knight" class="com.xxx.BraveKnight">
        <constructor-arg ref="quest">
    </bean>    
    <bean id="quest" class="com.xxx.SlayDragonKnight">
        <constructor-arg value="#{T(System).out}">
    </bean>
</beans>
```

通过java如下:
bean的id与方法名一致。

```
@Configuration
public class KnightConfig {
    @Bean
    public Knight knight() {
        return new BraveKnight(quest());
    }
    
    @Bean
    public CompactDisc sgtPeppers() {
        return new SgtPeppers();
    }
    
    # 以下两种方法等价
    @Bean
    public CDPlayer cdPlayer() {
        return new CDPlayer(sgtPeppers());
    }
    
    @Bean
    pubilc CDPlayer cdPlayer(CompactDisc compactDisc) {
        return new CDPlayer(compactDisc);
    }
}

@Configuration
@Bean
    * name="xxx"
```

组件扫描和自动装配:

```
@Component
@ComponentScan()  # 从哪些包中扫描
    * basePackages={"xxx1", "xxx2"}
    * basePackageClasses={XXX1.class, XXX2.class}
@ContextConfiguration()      # 配置类
    * classes=XXX.class
@Autowired
    * required=false
```

java注解

```
@Named
@Inject
```

>spring应用上下文(Application Context)全权负责对象的创建的装配。

spring中的每个bean都有一个ID，可指定可不指定，若不指定，则类名第一个字母小写即为ID。

#### AOP
面向切面编程可以让很多功能性代码(比如日志)脱离核心业务代码，使核心业务代码保持简单。实现方式如下:

* 通过xml文件实现AOP
* 通过注解实现(本质是基于代理的AOP)

通过xml文件实现AOP:

```
<?xml version="1.0" encoding="UTF-8">
<beans>
    <bean id="knight" class="com.xxx.BraveKnight">
        <constructor-arg ref="quest">
    </bean>    
    <bean id="quest" class="com.xxx.SlayDragonKnight">
        <constructor-arg value="#{T(System).out}">
    </bean>
    <bean id="minstrel" class="com.xxx.Minstrel">
        <constructor-arg value="#{T(System).out}">
    </bean>
    
    <aop:config>
        <aop:aspect ref="minstrel">
            <aop:pointcut id="embark" expression="execution(* *.embarkOnQuest(..))">   # 定义切点
            <aop:before pointcut-ref="embark" method="singBeforeQuest">
            <aop:after pointcut-ref="embark" method="singAfterQuest">
        </aop:aspect>
    </aop:config>
</beans>
```

#### 容器
>spring容器负责创建对象，装配它们，配置它们并管理它们的整个生命周期。

spring容器有多种实现。BeanFactory和ApplicationContext是其中的两种实现。

#### bean的生命周期

```
实例化
填充属性
调用BeanNameAware的setBeanName()方法
调用BeanFactoryAware的setBeanFactory方法
调用ApplicationContextAware的setApplicationContext()方法
调用BeanPostProcessor的与初始化方法
调用InitializingBean的afterPropertiesSet()方法
调用自定义的初始化方法
调用BeanPostProcessor的初始化方法
-----------------------
      bean创建完成
-----------------------
容器关闭
调用DisposableBean的destroy()方法
调用自定义的销毁方法
```