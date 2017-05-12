---
title: 实战篇-hexo和github搭建个人博客
date: 2017-03-25 16:17:47
tags:
    - blog
---

[安装node.js](https://nodejs.org/en/) 此时会安装node和npm(js的包管理工具)

### 安装hexo
```
npm install -g hexo
```

### 使用hexo

```
hexo init myblog #初始化博客目录
hexo generate    #生成静态页面
hexo server      #启动服务
```
此时访问http://127.0.0.1:4000 如果访问成功， 恭喜安装成功

### 与github关联
修改_confim.yml文件, 注意: 冒号后必须有空格

```
deploy:
  type: git
  repository: https://github.com/leopardpan/leopardpan.github.io.git
  branch: master
```
配置后执行如下命令

```
npm install hexo-deployer-git --save  #保存配置
hexo deploy                           #发布
```

### 常用命令

```
部署命令
hexo clean
hexo generate
hexo deploy

其他一些命令
hexo new "blog_name"      #新建一篇博客
hexo new page "page_name" #新建页面
hexo generate             #生成静态页面至public目录
hexo server               #启动本地服务调试
hexo deploy               #部署到github
```
### 好看的主题

[Cover](https://github.com/daisygao/hexo-themes-cover)
[Oishi](https://github.com/henryhuang/oishi)
[TKL](https://github.com/SuperKieran/TKL)
[Tinnypp](https://github.com/levonlin/Tinnypp)
[Writing](https://github.com/yunlzheng/hexo-themes-writing)
[Yilia 强烈推荐](https://github.com/litten/hexo-theme-yilia)
[Pacman](https://github.com/Voidly/pacman)

### Yilia主题相关
#### 支持latex
```
npm install hexo-math --save
hexo math install
```