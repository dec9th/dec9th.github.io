---
layout: post
title: "Redis Installation"
featured-img: logo-redis
categories: [redis]
---

# Overview

null yet!

# Install Redis

## 1. install requirement for Redis install 

```shell
$ yum -y install gcc gcc-c++ tcl jemalloc
```

## 2. set a environment like me

```shell
$ mkdir /app ; cd /app
```

## 3. Redis Source File 다운로드 

```shell
$ wget http://download.redis.io/releases/redis-4.0.2.tar.gz
$ tar zxvf redis-4.*
$ cd redis*
```

## 4. make 를 이용한 설치  

```shell
$ make
$ make test
$ make install
```


 ``make`` 간 ``jemalloc`` 관련하여 Error 발생 시 참고 : 먼저 1번의 ``jemalloc`` 설치 확인
 http://sharadchhetri.com/2015/07/07/jemallocjemalloc-h-no-such-file-or-directory-redis/


 반드시 ``make test`` 를 수행해서 *"\\o/ All tests passed without errors!"* 를 확인하셔서 찝찝함을 벗어 버리기 바랍니다.


# Install Redis instance 

## 1. Redis instace 서버 생성 실행

```shell
$ bash utils/install_server.sh

Welcome to the redis service installer
This script will help you easily set up a running redis server

Please select the redis port for this instance: [6379] Type "63790"
Please select the redis config file name [/etc/redis/63790.conf]  Type "Enter"
Selected default - /etc/redis/63790.conf 
Please select the redis log file name [/var/log/redis_63790.log] Type "/var/log/redis/63790.log"          
Please select the data directory for this instance [/var/lib/redis/63790]  Type " Enter" 
Selected default - /var/lib/redis/63790
Please select the redis executable path [/usr/local/bin/redis-server]  Type " Enter" 
Selected config:
Port           : 63790
Config file    : /etc/redis/63790.conf
Log file       : /var/log/redis/63790.log
Data dir       : /var/lib/redis/63790
Executable     : /usr/local/bin/redis-server
Cli Executable : /usr/local/bin/redis-cli
Is this ok? Then press ENTER to go on or Ctrl-C to abort.
Copied /tmp/63790.conf => /etc/init.d/redis_63790
Installing service...
Successfully added to chkconfig!
Successfully added to runlevels 345!
Starting Redis server...
Installation successful!
```

## 2. Using Redis as an LRU cache (http://redis.io/topics/lru-cache)

Cache 용도로 사용하기에 좋은 기능을 나타내는 LRU 기능입니다.  
번외로 실제 `save` 기능을 써 본 유저라면 Data 영속성을 위해 보관이 필요한 부분에 대해서는 RDBMS 혹은 NOSQL DB 중 하나인 MongoDB, CouchDB를 선호하는 것 같습니다.

실제 `maxmemory` 와 `maxmemory-policy` 설정을 통해 memory 과다 점유에 따른 **OOM** 혹은 *예기치 않은* **오작동** 을 막을 수 있습니다. 
여기서는 maxmemory 도달시 *모든 키 중에 최근 기준 제일 오랫동안 사용이 되지 않은 키를 제거* 하는 `allkeys-lru` 를 적용합니다.

```shell
$ vi /etc/redis/63790.conf
...
maxmemory 1gb
maxmemory-policy allkeys-lru
```

## 3. Tune to get rid of errors on starting

단순히 Server 튜닝 없이 위와 같이 설치할 경우 아래와 같이 에러가 발생합니다.

```shell
4252:M 21 Nov 12:45:04.960 # WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 128.
4252:M 21 Nov 12:45:04.960 # Server started, Redis version 3.2.5
4252:M 21 Nov 12:45:04.960 # WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
4252:M 21 Nov 12:45:04.960 # WARNING you have Transparent Huge Pages (THP) support enabled in your kernel. This will create latency and memory usage issues with Redis. To fix this issue run the command 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' as root, and add it to your /etc/rc.local in order to retain the setting after a reboot. Redis must be restarted after THP is disabled.
4252:M 21 Nov 12:45:04.960 * The server is now ready to accept connections on port 63790
```

이제 각 라인별 trouble shooting 을 해봅시다.

### 3.1. somaxconn 

```
WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 128.
```

위와 같은 경우 기본적으로 `somaxconn` 값이 128로 설정이 되어 있을텐데 redis 설정 내 `tcp-backlog` 를 `128`로 낮춰주던지 `511`이상으로 올려줄 필요가 있습니다.
Redis 설정을 변경하지 않고 아래와 같이 somaxconn 부분을 튜닝해봅시다. 본 예제는 1024 로 설정합니다.

```shell
$ echo 1024 > /proc/sys/net/core/somaxconn
```

### 3.2. overcommit_memory

```shell
WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
```

약간 설명을 하자면 잔여 물리메모리가 부족할 경우 **swap(disk)** 을 사용해서까지 할당하겠느냐라고 우선 이해하고 넘어갑니다.
Cache 성으로 사용 시 크게 이슈가 되지 않지만 `save` 관련 기능 사용 시 이슈 방지를 위해 미리 넣어둔다고 봐도 좋습니다.
`save`가 아니더라도 본인의 경우 t2.micro로 사이트를 운영하고 있는데 redis 다운 방지를 위해 maxmemory & swap disk와 함께 본 기능으로 다운없이 운영 중 입니다.

친절하게도 WARNING 메시지에 표기된 바와 같이 설정하면 즉시 설정 변경 가능합니다. 

```shell
sysctl vm.overcommit_memory=1
```

본 튜닝을 떠나 빈번한 swap 사용 시 서비스 지연이 발생 할 수 있으므로 모니터링 간 Swap 사용에 대한 체크가 필요합니다.

### 3.3. transparent_hugepage

```shell
WARNING you have Transparent Huge Pages (THP) support enabled in your kernel. This will create latency and memory usage issues with Redis. To fix this issue run the command 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' as root, and add it to your /etc/rc.local in order to retain the setting after a reboot. Redis must be restarted after THP is disabled.
```

간략히 설명을 하자면 본 *THP* 인해 지연 초래 및 메모리 사용 이슈가 있다고 합니다.  실제 Reference를 보면 안 사용할 이유는 찾기 쉽지 않으나 잦은 이슈 리포팅 & FOSS Official 에서 `never` 로 가는 추세인 것으로 보입니다.

본 건 역시 WARNING 메시지에 표기된 바와 같이 변경 가능합니다.

```shell
echo never > /sys/kernel/mm/transparent_hugepage/enabled
```



지금쯤 설명하는 것은 필자는 Production 환경의 서버들 역시 필요하지 않은 튜닝에 대해 선제적용하지 않는다는 기본 철학과 동시에
한가지 변경은 한가지 이상의 수정을 낳을 수 있기에 또한 나보다 서비스가 오래살 수 있기에 누군가 내 서비스를 볼 때 **"왜?"** 라는 생각과 함께 시간을 낭비하는 것을 원치 않습니다.

즉, 불필요하고 **무의미한** 튜닝을 하지 않습니다.
*"Keep it very simple!"*

자! 서비스 시작 간 에러에 대해 이해하셨다고 보고 Product에서 적용할 수 있는 튜닝 가이드를 소개 합니다. 
*실제 초급 엔지니어가 아니라면 위와 같이 설정하지 않습니다.*

Edit "/etc/sysctl.conf" :

```shell
#
# Santa Style [Set real mine:All Servers]
# File : /etc/sysctl.conf
#
# net.ipv4.tcp_tw_recycle = 1 # never use for front
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_max_orphans = 60000
net.ipv4.tcp_max_syn_backlog = 10240
net.ipv4.tcp_max_tw_buckets = 400000
net.ipv4.ip_local_port_range = 1024 65000
net.core.somaxconn = 10240
net.core.netdev_max_backlog = 10240

#3.2. tune memory overcommit for Redis
vm.overcommit_memory=1
```

**Disable Transparent Huge Pages** 부분은 아래 mongodb official site에 정리가 잘되어 있으니 참고해서 Product에서 사용하길 바랍니다.

*Disable THP* (http://docs.mongodb.org/manual/tutorial/transparent-huge-pages/)
