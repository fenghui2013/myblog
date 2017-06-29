---
title: 实战篇-redis相关日志
date: 2017-06-17 15:15:56
tags:
    - redis
---

### 主从复制

#### 一主两从

```
# 主节点
3215:M 07 Jun 06:58:47.793 * DB loaded from append only file: 0.000 seconds
3215:M 07 Jun 06:58:47.793 * The server is now ready to accept connections on port 6379


# 从节点
3222:S 07 Jun 06:59:45.630 * DB loaded from append only file: 0.000 seconds
3222:S 07 Jun 06:59:45.630 * The server is now ready to accept connections on port 6380
3222:S 07 Jun 06:59:45.630 * Connecting to MASTER 127.0.0.1:6379
3222:S 07 Jun 06:59:45.630 * MASTER <-> SLAVE sync started
3222:S 07 Jun 06:59:45.630 * Non blocking connect for SYNC fired the event.
3222:S 07 Jun 06:59:45.630 * Master replied to PING, replication can continue...
3222:S 07 Jun 06:59:45.630 * Partial resynchronization not possible (no cached master)
3222:S 07 Jun 06:59:45.632 * Full resync from master: 2fdcd7b48c6db57255a12429a04b7a92e3a06082:1
3222:S 07 Jun 06:59:45.732 * MASTER <-> SLAVE sync: receiving 149 bytes from master
3222:S 07 Jun 06:59:45.732 * MASTER <-> SLAVE sync: Flushing old data
3222:S 07 Jun 06:59:45.732 * MASTER <-> SLAVE sync: Loading DB in memory
3222:S 07 Jun 06:59:45.732 * MASTER <-> SLAVE sync: Finished with success
3222:S 07 Jun 06:59:45.734 * Background append only file rewriting started by pid 3226
3222:S 07 Jun 06:59:45.763 * AOF rewrite child asks to stop sending diffs.
3226:C 07 Jun 06:59:45.763 * Parent agreed to stop sending diffs. Finalizing AOF...
3226:C 07 Jun 06:59:45.763 * Concatenating 0.00 MB of AOF diff received from parent.
3226:C 07 Jun 06:59:45.764 * SYNC append only file rewrite performed
3226:C 07 Jun 06:59:45.764 * AOF rewrite: 6 MB of memory used by copy-on-write
3222:S 07 Jun 06:59:45.833 * Background AOF rewrite terminated with success
3222:S 07 Jun 06:59:45.833 * Residual parent diff successfully flushed to the rewritten AOF (0.00 MB)
3222:S 07 Jun 06:59:45.835 * Background AOF rewrite finished successfully
```

### sentinel

#### 一主两从 四个sentinel

```
# sentinel节点
3428:X 07 Jun 07:35:03.954 # Sentinel ID is 260e9ef949d16eaa2b6f603b45f5eb184ada8a59
3428:X 07 Jun 07:35:03.954 # +monitor master mymaster 127.0.0.1 6379 quorum 2
3428:X 07 Jun 07:35:03.955 * +slave slave 127.0.0.1:6380 127.0.0.1 6380 @ mymaster 127.0.0.1 6379
3428:X 07 Jun 07:35:03.956 * +slave slave 127.0.0.1:6381 127.0.0.1 6381 @ mymaster 127.0.0.1 6379
3428:X 07 Jun 07:35:03.957 * +slave slave 127.0.0.1:6382 127.0.0.1 6382 @ mymaster 127.0.0.1 6379
3428:X 07 Jun 07:35:27.318 * +sentinel sentinel 6a33cb60ba555f2f8cc197e248b9d6897203777f 127.0.0.1 26380 @ mymaster 127.0.0.1 6379
3428:X 07 Jun 07:35:30.691 * +sentinel sentinel 7938ad3e26bd62a523750ed7f22020658b1720c9 127.0.0.1 26381 @ mymaster 127.0.0.1 6379
3428:X 07 Jun 07:35:33.054 * +sentinel sentinel bb76a725c52efe13742e915b8b9e4b16324d2ccb 127.0.0.1 26382 @ mymaster 127.0.0.1 6379
```

#### 宕掉一个sentinel节点

```
# sentinel节点
3428:X 07 Jun 07:41:12.726 # +sdown sentinel bb76a725c52efe13742e915b8b9e4b16324d2ccb 127.0.0.1 26382 @ mymaster 127.0.0.1 6379
```

#### 宕掉一个从节点

```
# 主节点
3396:M 07 Jun 07:38:50.317 # Connection with slave 127.0.0.1:6382 lost.

# sentinel节点
3428:X 07 Jun 07:39:20.380 # +sdown slave 127.0.0.1:6382 127.0.0.1 6382 @ mymaster 127.0.0.1 6379
```

对sentinel节点和其他redis节点无影响

#### 宕掉主节点

```
#领头sentinel节点
3428:X 07 Jun 07:43:28.749 # +sdown master mymaster 127.0.0.1 6379
3428:X 07 Jun 07:43:28.840 # +odown master mymaster 127.0.0.1 6379 #quorum 2/2
3428:X 07 Jun 07:43:28.840 # +new-epoch 1
3428:X 07 Jun 07:43:28.840 # +try-failover master mymaster 127.0.0.1 6379
3428:X 07 Jun 07:43:28.843 # +vote-for-leader 260e9ef949d16eaa2b6f603b45f5eb184ada8a59 1
3428:X 07 Jun 07:43:28.849 # 7938ad3e26bd62a523750ed7f22020658b1720c9 voted for 260e9ef949d16eaa2b6f603b45f5eb184ada8a59 1
3428:X 07 Jun 07:43:28.855 # 6a33cb60ba555f2f8cc197e248b9d6897203777f voted for 260e9ef949d16eaa2b6f603b45f5eb184ada8a59 1
3428:X 07 Jun 07:43:28.897 # +elected-leader master mymaster 127.0.0.1 6379
3428:X 07 Jun 07:43:28.897 # +failover-state-select-slave master mymaster 127.0.0.1 6379
3428:X 07 Jun 07:43:28.970 # +selected-slave slave 127.0.0.1:6380 127.0.0.1 6380 @ mymaster 127.0.0.1 6379
3428:X 07 Jun 07:43:28.970 * +failover-state-send-slaveof-noone slave 127.0.0.1:6380 127.0.0.1 6380 @ mymaster 127.0.0.1 6379
3428:X 07 Jun 07:43:29.061 * +failover-state-wait-promotion slave 127.0.0.1:6380 127.0.0.1 6380 @ mymaster 127.0.0.1 6379
3428:X 07 Jun 07:43:29.067 # +promoted-slave slave 127.0.0.1:6380 127.0.0.1 6380 @ mymaster 127.0.0.1 6379
3428:X 07 Jun 07:43:29.067 # +failover-state-reconf-slaves master mymaster 127.0.0.1 6379
3428:X 07 Jun 07:43:29.125 * +slave-reconf-sent slave 127.0.0.1:6381 127.0.0.1 6381 @ mymaster 127.0.0.1 6379
3428:X 07 Jun 07:43:29.970 # -odown master mymaster 127.0.0.1 6379
3428:X 07 Jun 07:43:30.072 * +slave-reconf-inprog slave 127.0.0.1:6381 127.0.0.1 6381 @ mymaster 127.0.0.1 6379
3428:X 07 Jun 07:43:30.072 * +slave-reconf-done slave 127.0.0.1:6381 127.0.0.1 6381 @ mymaster 127.0.0.1 6379
3428:X 07 Jun 07:43:30.143 # +failover-end master mymaster 127.0.0.1 6379
3428:X 07 Jun 07:43:30.144 # +switch-master mymaster 127.0.0.1 6379 127.0.0.1 6380
3428:X 07 Jun 07:43:30.144 * +slave slave 127.0.0.1:6381 127.0.0.1 6381 @ mymaster 127.0.0.1 6380
3428:X 07 Jun 07:43:30.144 * +slave slave 127.0.0.1:6382 127.0.0.1 6382 @ mymaster 127.0.0.1 6380
3428:X 07 Jun 07:43:30.144 * +slave slave 127.0.0.1:6379 127.0.0.1 6379 @ mymaster 127.0.0.1 6380
3428:X 07 Jun 07:44:00.184 # +sdown slave 127.0.0.1:6379 127.0.0.1 6379 @ mymaster 127.0.0.1 6380
3428:X 07 Jun 07:44:00.185 # +sdown slave 127.0.0.1:6382 127.0.0.1 6382 @ mymaster 127.0.0.1 6380

# 其他sentinel节点
3433:X 07 Jun 07:43:28.803 # +sdown master mymaster 127.0.0.1 6379
3433:X 07 Jun 07:43:28.851 # +new-epoch 1
3433:X 07 Jun 07:43:28.855 # +vote-for-leader 260e9ef949d16eaa2b6f603b45f5eb184ada8a59 1
3433:X 07 Jun 07:43:28.862 # +odown master mymaster 127.0.0.1 6379 #quorum 3/2
3433:X 07 Jun 07:43:28.862 # Next failover delay: I will not start a failover before Wed Jun  7 07:49:28 2017
3433:X 07 Jun 07:43:29.130 # +config-update-from sentinel 260e9ef949d16eaa2b6f603b45f5eb184ada8a59 127.0.0.1 26379 @ mymaster 127.0.0.1 6379
3433:X 07 Jun 07:43:29.130 # +switch-master mymaster 127.0.0.1 6379 127.0.0.1 6380
3433:X 07 Jun 07:43:29.130 * +slave slave 127.0.0.1:6381 127.0.0.1 6381 @ mymaster 127.0.0.1 6380
3433:X 07 Jun 07:43:29.131 * +slave slave 127.0.0.1:6382 127.0.0.1 6382 @ mymaster 127.0.0.1 6380
3433:X 07 Jun 07:43:29.131 * +slave slave 127.0.0.1:6379 127.0.0.1 6379 @ mymaster 127.0.0.1 6380
3433:X 07 Jun 07:43:59.148 # +sdown slave 127.0.0.1:6382 127.0.0.1 6382 @ mymaster 127.0.0.1 6380
3433:X 07 Jun 07:43:59.148 # +sdown slave 127.0.0.1:6379 127.0.0.1 6379 @ mymaster 127.0.0.1 6380
```

