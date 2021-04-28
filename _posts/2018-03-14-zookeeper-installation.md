---
layout: post
title:  "Zookeeper 설치"
categories: Zookeeper 
tags: zookeeper
comments: true
author: santa, kkane123
---

*Tested all on Amazon linux2*

# Overview

Zookeeper는 분산 코디네이션으로 사용되는 OpenSource proeject 중 하나 입니다. 
저 같은 경우엔 주로 접근 이후 잘 변경되지 않은 User Session 및 TCP Socket 등을 사용하는 서버 관리를 위해 사용하고 있습니다. 
google에서 검색되는 성능 관련 몇몇의 post들을 보면 Read/Write 비율 1/9 비율로 사용하는 것이 좋다고 이야기합니다. 
성능 테스트에 덧붙여 Snapshot 남기는 것 역시 부하이기에 최소화 시키기 위하여 Write 비율이 낮고 세션 변경 확인을 위한 잦은 Read를 하게되는 **세션** 및 **서버노드관리** 의 경우 추천 드립니다. 
본 건에 대해서 어떻게 쓰면 좋을지에 대해서 언젠가 별도 chatting code와 함께 사용 리뷰하도록 할 계획입니다..... 언젠가...
 
# 사전 조건

Server 3대로 Cluster(앙상블)을 구성합니다.(단일 서버로도 가능)

Hostname | IP
--- | ---
zk01 | 10.1.1.101
zk02 | 10.1.1.102
zk03 | 10.1.1.103

미리 Security Groups(or Firewall, ACL, IPtables) 등의 접근 제어가 되고 있다면 아래 참고하셔서 미리 허용이 필요합니다.

Port | Comment 
--- | --- | ---
2181 | Service port
2888 | Leader port
3888 | Follow port

그리고 모든 명령어는 모든 서버에 동일하게 입력하시면 됩니다. (`myid`만 예외)

# Installation

## 1. 작업 디렉토리 생성

전 보통 `/app` 위에 Application을 별도 관리하고 있습니다, 변경을 원할 경우 입맛에 맞게 변경하셔도 좋습니다.

```bash
# Zookeeper in /app
mkdir /app
cd /app

# Zookeeper data Directroy 
mkdir -pv /data1/zookeeper

# Zookeeper needs Java, netcat 
yum -y install java-1.8.0-openjdk-devel nc
```
 
## 2. Download 

이 글을 쓰는 시점에 `3.4.11`버전이 나와있는데요 `Datadir` 이슈가 있어서 쓰시면 안됩니다! 

```shell 
wget http://www-us.apache.org/dist/zookeeper/zookeeper-3.4.10/zookeeper-3.4.10.tar.gz
tar zxvf zookeeper-3.4.10.tar.gz
mv zookeeper-3.4.10 zookeeper
```
 
## 3. 설정 변경

시작 시 config가 없고 Cluster Mode를 사용하기 위해 아래와 같이 `zoo_sample.cfg`파일을 `zoo.cfg`파일로 변경 후 사용가능합니다.

```
cd zookeeper/conf
cp zoo_sample.cfg zoo.cfg
vi zoo.cfg
```

설정은 log 및 data 그리고 cluster 설정 정도 하고자 합니다. 
아래와 같이 설정울 변경 및 추가하시면 됩니다. 

```
...
dataDir=/data1/zookeeper
...
autopurge.snapRetainCount=3
autopurge.purgeInterval=1
...
# Cluster 
server.1=10.1.1.101:2888:3888
server.2=10.1.1.102:2888:3888
server.3=10.1.1.103:2888:3888
```

**OPTION 설명** : 

- `tickTime`: Heartbeat 간 사용되는 timeout
- `dataDir`: Data디렉토리로 사용되며 **Producton**환경에서는 분리필요!! (성능가 발생할 정도라면 반드시 분리)
- `clientPort`: Service port
- `initLimit`: 책임자 연결에 허용된 시간, 과반수 후보자가   초과시 다른 책임자 선출
- `syncLimit`: 후보자에게 허용된 data sync 시간, 초과시 클라이언트는 다른 서버로 연결

- `autopurge.snapRetainCount`: 여기서는 3개를 남기고 모두 지우도록 입력했습니다.
- `autopurge.purgeInterval`: 1 시간 마다 스냅샷을 찍어냅니다.  (기본값은 0이며, 0이면 동작하지 않음)

- `server.1=10.1.1.101:2888:3888`: `1`은 myid, `10.1.1.101`은 myid1의 IP, `2888`은 follow가 leader와의 통신간 사용하는 port, `3888`은 리더선출을 위한 port   


## 4. myid 설정

클러스터링에 참여하는 주키퍼 서버는 1~255까지의 고유한 id를 가지고 있어야 합니다.
`dataDir` 폴더에 myid 라는 파일을 만들고 서버의 번호를 기재 합니다.

The myid file consists of a single line containing only the text of that machine's id. So myid of server 1 would contain the text "1" and nothing else. The id must be unique within the ensemble and should have a value between 1 and 255.
- 출처 : https://zookeeper.apache.org/doc/trunk/zookeeperAdmin.html

즉, Cluster 간 서로 식별을 위해 각기 다른 id를 가집니다. 아래와 같이 설정 할 수 있습니다. 

- _zk01_ 서버 내 입력 

```
echo 1 > /data1/zookeeper/myid
```
- _zk02_ 서버 내 입력 

```
echo 2 > /data1/zookeeper/myid
```

- _zk03_ 서버 내 입력 

```
echo 3 > /data1/zookeeper/myid
```

## 5. Heap 설정

Java Heap 설정은 JVM Default 설정을 따라갑니다. 필요없다면 안하시고 건너 뛰셔도 됩니다.
1GB일 경우 아마 1/4 계산해서 Max Heap(`Xmx`)를 256MB 잡습니다.
memory가 1GB 밖에 없다면 아래 메모리를 더 작게 설정해야합니다. 언젠가 `OutOfKill`을 맛볼 수 있습니다.

```
echo 'export JVMFLAGS="-Xmx1024m"' | tee /app/zookeeper/conf/java.env
```

## 6. Zookeeper system log 설정

아마 zookeeper 기본 설정에는 안 보일텐데요. 실제 변경을 하려면 `zkEnv.sh`를 변경하면 되나 뭔가 여러 설정을 할 수 있는 `zkEnv.sh`을 변경하는 것을 추천 드리진 않습니다.
`zookeeper-env.sh`를 기본적으로 읽어오긴 하나 실제 설치 파일 내 기본 제공되지 않기에 편하게 그냥 하나 만드시면 됩니다.

```
echo ZOO_LOG_DIR="/data1/zookeeper" | tee /app/zookeeper/conf/zookeeper-env.sh
```

## 7. manage zookeeper daemon

- Start Zookeeper server

```
/app/zookeeper/bin/zkServer.sh start
```

- Stop Zookeeper server

```
/app/zookeeper/bin/zkServer.sh stop
```

본 과정으로 사실상 설치는 완료됩니다.

## 8. Check Zookeeper Server

zookeeper는 4개의 글자만 가지고 운영하도록 설계해두었습니다. 

- 상태 확인 (only ping)

```
echo ruok | nc localhost 2181

# output: 
imok
```

- 주요 성능 지표 

```
echo mntr | nc localhost 2181

# output:
zk_version	3.4.10-39d3a4f269333c922ed3db283be479f9deacaa0f, built on 03/23/2017 10:13 GMT
zk_avg_latency	0
zk_max_latency	0
zk_min_latency	0
zk_packets_received	3
zk_packets_sent	2
zk_num_alive_connections	1
zk_outstanding_requests	0
zk_server_state	follower
zk_znode_count	4
zk_watch_count	0
zk_ephemerals_count	0
zk_approximate_data_size	27
zk_open_file_descriptor_count	29
zk_max_file_descriptor_count	4096
```

- 설정 확인

```
echo conf | nc localhost 2181

# output:
clientPort=2181
dataDir=/data1/zookeeper/version-2
dataLogDir=/data1/zookeeper/version-2
tickTime=2000
maxClientCnxns=60
minSessionTimeout=4000
maxSessionTimeout=40000
serverId=1
initLimit=10
syncLimit=5
electionAlg=3
electionPort=3888
quorumPort=2888
peerType=0
```
- 연결된 세션 확인

```
echo cons | nc localhost 2181

# output:
 /127.0.0.1:60930[0](queued=0,recved=1,sent=0)
```

이 외엔 거의 중복되며 watcher 부분만 watcher 사용 시 한번 확인해보면 좋습니다.

# Production 간 제언
설정에 크게 기본에 벗어날 수 있는 부분은 Zookeeper가 생산할 수 있는 3가지의 데이터 및 로그가 있습니다. 
`datadir`에 남게되는 snapshot, `datalogdir`에 기록되는 transation log 그리고 나머지 하나인 Zookeeper system log가 `ZOO_LOG_DIR` 에 기록되는 부분이 있습니다.
Zookeeper log를 제외하고 datalogdir, datalog의 경우엔 Disk Write에 영향을 미칠 수 있으니 production간 부하 관련 우려가 발생할 수 있기에 별도로 분리하는 것이 좋습니다.
_본 글에서는 `datalogdir`을 다루진 않았습니다._

또 하나.. `snapshot`관리를 위해 `autopurge.snapRetainCount`, `autopurge.purgeInterval` 를 사용합니다.  특정버전에서 default가 적용되지 않아서 직접 설정해서 사용했던 기억이 있습니다. 
실제 Disk size 고려하여 설정하셔도 되고 저 같은 경우 보험용으로 3개 정도만 적재해두고 있습니다. 세션용도로 사용하게 될 경우 서비스가 잘나갈경우 `disk` 관리가 부담스럽게 될 수 있습니다. 이런 경우 10개 이상 남길필요는 없으니 촘촘히 잘 설정하시기 바랍니다. 

아래 Reference 내 zookeeper 공식 사이트 하단에 있는 **Things to Avoid**를 본 글에서 조금 다루었는데요. 본 글 이후 production 환경에서 사용을 위해 한번은 더 보시면 좋을 것 같습니다.

특성상 Write만 과하게 일으키지 않는다면 위에 대한 이슈는 없을 수 있습니다만 발뻣고 자기 위해 적당한 모니터링과 `data*` 설정을 통해 분리된 disk에 적재하시길 권고드립니다.


# Reference

**https://zookeeper.apache.org/doc/r3.4.2/zookeeperAdmin.html**

http://kimseunghyun76.tistory.com/397  

http://advent.perl.kr/2012/2012-12-24.html

http://over153cm.tistory.com/22

http://creatorw.tistory.com/52
