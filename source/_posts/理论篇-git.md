---
title: 理论篇-git
date: 2017-09-06 14:17:33
tags:
    - git
---

#### git的特性

##### 分支与合并

* 平滑的上下文切换
* 基于角色的代码边界(主分支(生产分支)，测试分支，开发分支)
* 基于功能的工作流
* 一次性实验(可大胆的创建分支，测试新想法，如果行不通，删除即可)

##### 小且快

##### 分布式

* 多备份
* 任意工作流
    * subversion风格的工作流
    * 整合管理者工作流(大部分的开源项目)
    * 独裁者与助理工作流(linux内核)

##### 数据安全性

##### 缓存区域(staging area)

```
.
├── .git
│   ├── COMMIT_EDITMSG
│   ├── HEAD
│   ├── config
│   ├── description
│   ├── hooks
│   │   ├── applypatch-msg.sample
│   │   ├── commit-msg.sample
│   │   ├── post-update.sample
│   │   ├── pre-applypatch.sample
│   │   ├── pre-commit.sample
│   │   ├── pre-push.sample
│   │   ├── pre-rebase.sample
│   │   ├── pre-receive.sample
│   │   ├── prepare-commit-msg.sample
│   │   └── update.sample
│   ├── index
│   ├── info
│   │   └── exclude
│   ├── logs
│   │   ├── HEAD
│   │   └── refs
│   │       ├── heads
│   │       │   └── master
│   │       └── remotes
│   │           └── origin
│   │               ├── HEAD
│   │               └── master
│   ├── objects
│   │   ├── 03
│   │   │   └── 608c266fb496e0d0e91c47d12feff94d51979b
│   │   ├── 14
│   │   │   └── faa91e92bf4b5ae35741e6dd21f96a18ee9434
│   │   ├── 1d
│   │   │   └── a5ff9f64b8f9c3242c4b64c60b7ecc8d7a3317
│   │   ├── 3a
│   │   │   └── dba43c276a46951f7876286bfad676a33ac791
│   │   ├── 3d
│   │   │   └── 07907040eb486cdd6591d8beb35cca88cf4f05
│   │   ├── 40
│   │   │   ├── 5d7004636a4ac3982d1a004abc3cdb728d5c84
│   │   │   └── ad0beaedb60fd54bb50944aa29daa92165019d
│   │   ├── 64
│   │   │   └── ab44c069ec429ab7baf6907b39372d01712491
│   │   ├── 68
│   │   │   └── b961c0c93dc52a9b4ecd7365e1e9c8228335b0
│   │   ├── 75
│   │   │   └── 59f2dfc904e98ba4502d61d58b259ac26bd963
│   │   ├── 79
│   │   │   └── e1b4e4a5b4749ef38580354e0b4e86e936e8b2
│   │   ├── 7a
│   │   │   └── 00c826727b14e260fef04044892644f6e66edd
│   │   ├── 86
│   │   │   └── 729e808d7a9aa1b98f401b07e310f9d11fb973
│   │   ├── 88
│   │   │   └── b7c625f15d3a5209630b2ce1ec795c32a96930
│   │   ├── 93
│   │   │   └── 1f34e56c1fde33acbe15f68e5950b6c8abdefd
│   │   ├── 9a
│   │   │   └── 0d2d51ee1717285828be51dafc21d87711ec01
│   │   ├── a4
│   │   │   └── e3d834847f446a2859cc0e8c6e9845246e241f
│   │   ├── aa
│   │   │   ├── 48aa278cf2c02f5d726fd3e01f531e1094c8d3
│   │   │   └── 66490c4fbeef674f150e4fe4ceeed01afaa868
│   │   ├── ba
│   │   │   └── f13061a7bcea6f8386d5432059508e6acfa6f6
│   │   ├── cd
│   │   │   └── 7b9c523a676d03d49bbf1a8110d8c329ab55be
│   │   ├── ce
│   │   │   └── a79cfa9f191becece59f9e4019d469fe3554a0
│   │   ├── d5
│   │   │   └── 376c8519e1a8bb32757e5b3296af0b5727be0f
│   │   ├── d7
│   │   │   └── 87f36cc59c608571c09cc6fd65d2d7a3af1833
│   │   ├── dd
│   │   │   └── 4c7cc4fec679c0dc3efa1539a28b4a2357c23f
│   │   ├── e3
│   │   │   ├── 2b361902897d9541d5db5e60752d6fab0aa22a
│   │   │   └── 606e7342764b9d8ed8f20da9731d4024cee3cd
│   │   ├── ed
│   │   │   └── cc7eed7a720a8a28f14511837820849e3390d4
│   │   ├── f6
│   │   │   └── 9a3d7ea4f061a6a1e62d4ab61dbac717e2a473
│   │   ├── fa
│   │   │   └── 104313f955fdacf41edd819cd88e4533275e9a
│   │   ├── info
│   │   └── pack
│   ├── packed-refs
│   └── refs
│       ├── heads
│       │   └── master
│       ├── remotes
│       │   └── origin
│       │       ├── HEAD
│       │       └── master
│       └── tags
├── .vimrc
└── README.md
```


**checkout**

```
git checkout [-q] [-f] [-m] [<branch>]  # 切换分支
git checkout [-q] [-f] [-m] [--detach] <commit>  # 切换到任何一次提交
git checkout [-p|--patch] [<tree-ish>] [--] [<paths>...] # 检出其它提交的某些文件 若不指定<tree-ish> 则从暂存区中检出
```

**常见用法**

* 切换到某个分支
* 检出某个分支上的某些文件并替换工作区中的文件
* 检出某个分支，做完修改后，在此基础上创建新的分支


**branch**

```
git branch [--set-upstream | --track | --no-track] [-l] [-f] <branchname> [<start-point>]  # 根据某个提交创建分支
```

### reference

[git中文版](https://www.git-scm.com/book/zh/v2)

[阮一峰网站](http://www.ruanyifeng.com/blog/2014/06/git_remote.html)