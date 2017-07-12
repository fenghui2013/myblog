---
title: 实战篇-tornado之性能测试
date: 2017-07-04 15:43:59
tags:
    - tornado
---

cpu | 内存
----|-----
4 | 4GB

```
processor	: 0
vendor_id	: GenuineIntel
cpu family	: 6
model		: 69
model name	: Intel(R) Core(TM) i3-4010U CPU @ 1.70GHz
stepping	: 1
microcode	: 31
cpu MHz		: 782.000
cache size	: 3072 KB
physical id	: 0
siblings	: 4
core id		: 0
cpu cores	: 2
apicid		: 0
initial apicid	: 0
fpu		: yes
fpu_exception	: yes
cpuid level	: 13
wp		: yes
flags		: fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ss ht tm pbe syscall nx pdpe1gb rdtscp lm constant_tsc arch_perfmon pebs bts rep_good xtopology nonstop_tsc aperfmperf pni pclmulqdq dtes64 monitor ds_cpl vmx est tm2 ssse3 fma cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic movbe popcnt tsc_deadline_timer xsave avx f16c rdrand lahf_lm abm ida arat epb xsaveopt pln pts dtherm tpr_shadow vnmi flexpriority ept vpid fsgsbase bmi1 avx2 smep bmi2 erms invpcid
bogomips	: 3392.12
clflush size	: 64
cache_alignment	: 64
address sizes	: 39 bits physical, 48 bits virtual
power management:
```

**进程数: 1**

请求数 | 并发数 | QPS | time(s) | 特殊说明
-----|--------|-----|-------|-----
10000 | 1 | 796 | 12 | 单核cpu: 100%
10000 | 2 | 815 | 12 | 单核cpu: 100%
10000 | 4 | 819 | 12 | 单核cpu: 100%
10000 | 8 | 817 | 12 | 单核cpu: 100%
50000 | 16 | 818 | 61 | 单核cpu: 100%
50000 | 32 | 818 | 61 | 单核cpu: 100%
50000 | 64 | 813 | 61 | 单核cpu: 100%


**进程数: 4**

请求数 | 并发数 | QPS | time(s) | 特殊说明
-----|--------|-----|-------|--------
10000 | 1 | 386 | 25 | cpu: 40%
10000 | 2 | 1295 | 7 | cpu: 70%
10000 | 4 | 1683 | 6 | cpu: 100%
10000 | 8 | 1681 | 6 | cpu: 100%
50000 | 16 | 1677 | 30 | cpu: 100%
50000 | 32 | 1675 | 30 | cpu: 100%
50000 | 64 | 1675 | 30 | cpu: 100%


#### peewee

**进程数: 4 连接池: 4**

请求数 | 并发数 | QPS | time(s) | 特殊说明
-----|--------|-----|-------|--------
10000 | 1 | 213 | 46 | cpu: 40%
10000 | 2 | 631 | 15 | cpu: 60%
10000 | 4 | 893 | 11 | cpu: 88%
10000 | 8 | 890 | 11 | cpu: 88%

**备注:** 由于数据库与服务部署在同一台机器上，数据库也占用了部分计算资源，所以整个机器的cpu利用率达到了100%，但是服务占用的只有88%。


