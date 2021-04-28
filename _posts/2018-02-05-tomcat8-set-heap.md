---
layout: post
title:  "Set heap size in tomcat8"
categories: ["java", "tomcat"]
featured-img: logo-tomcat
---

*Tested all on tomcat8*

# Overview

`tomcat7`까지는 `catalina.sh` 에서 처리가 가능하였으나 `OPT` 설정이 많아 지면서 `setenv.sh`에서 사용하는게 오히려 서비스 간 간결함을 유지 할 수 있습니다.
실제 어디서 설정을 하든 상관없으나 `setenv.sh`는 설치 간 존재하지 않기에 별도로 만들어서 `ansible`과 같은 **CM**으로 관리하기에 한결 편하고 버전에 따라 변할 수 있는 `catalina.sh`와 관계없이 **일관성**을 유지할 수 있습니다.  

# Set Java heap size

## 1. Go to tomcat's bin directory

아래는 `/app/tomcat`이 `$TOMCAT_BASE`가 되는 경우입니다.

```shell
cd /app/tomcat/bin
```
 
## 2. add "setenv.sh" as below

기본적으로 시스템, 백업을 고민하여 *하프* 정도 남겨두는 것이 좋습니다. 
Memory 2GB인 Box에 아래와 같이 튜닝했던 값입니다.

```shell
export CATALINA_OPTS="$CATALINA_OPTS -Xms512m"
export CATALINA_OPTS="$CATALINA_OPTS -Xmx1024m"
export CATALINA_OPTS="$CATALINA_OPTS -XX:MaxPermSize=256m"
```
 
실제 글로벌하게 선언된 `OPT` 설정이 주석처리 됨에 따라 해당 변수를 쭉 따라가지 않을 거라면 그리고 공통되게 사용하고자 한다면 `setenv.sh`를 쓰는 것이 제일 베스트한 방법 중의 하나로 보입니다. 
아래와 같이 `catalina.sh`에서 `setenv.sh`를 호출하는 것을 확인할 수 있습니다

```shell
[root@ops01]# grep setenv /app/tomcat/bin/catalina.sh   
#   setenv.sh in CATALINA_BASE/bin to keep your customizations separate.
# but allow them to be specified in setenv.sh, in rare case when it is needed.
if [ -r "$CATALINA_BASE/bin/setenv.sh" ]; then
  . "$CATALINA_BASE/bin/setenv.sh"
elif [ -r "$CATALINA_HOME/bin/setenv.sh" ]; then
  . "$CATALINA_HOME/bin/setenv.sh"
```

# Reference

http://crunchify.com/how-to-change-jvm-heap-setting-xms-xmx-of-tomcat/
