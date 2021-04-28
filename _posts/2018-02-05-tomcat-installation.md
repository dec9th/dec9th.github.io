---
layout: post
title:  "How to install tomcat8"
categories: ["java", "tomcat"]
featured-img: logo-tomcat
---

*Tested all on Amazon Linux2*

# Overview

tomcat 8.5까지는 아래 버전으로 무난하게 설치 될 것 같습니다. 설정 가이드를 제외하고는 10년 전 제 블로그 자료라 왠만해서는 변할 일 없을 것 같습니다.

# Installation

## java8 설치

```shell
yum -y install java-1.8.0-openjdk-devel  
```


## 기존에 설치된 java7 제거 

- `amazonlinux`는 기본적으로 `java7`가 설치되어 있으며 `alternatives`에 기본적으로 1.7을 물고 올라오기에 아래와 같이 삭제하지 않을 경우 `alternatives`를 통해 반드시 1.8로 변경하셔서 사용바랍니다.
- `amazonlinux2`는 기본적으로 `java7`가 설치되어 있지 않아 건너 뛰셔도 좋습니다. 

```shell
yum erase java-1.7.0-openjdk
```

## application directory 생성

```shell
mkdir /app
```


## tomcat download

```shell
wget http://apache.tt.co.kr/tomcat/tomcat-8/v8.0.35/bin/apache-tomcat-8.0.35.tar.gz
```

## tomcat 설치(압축해제)

```shell
tar zxvf apache-tomcat-8.0.35.tar.gz -C /app
mv /app/apache-tomcat-* /app/tomcat
```


# tomcat daemon 제어

## 시작 

```shell
/app/tomcat/bin/startup.sh  
```

## 중지

```shell
/app/tomcat/bin/shutdown.sh
```

# tomcat 설정

## Edit `/app/tomcat/conf/server.xml` - document base 변경

`docbase`의 경우 아래와 같이 편하게 변경하여 사용 가능하며 `path`는 스스로 작성한 API 명세서 참고하여 알맞게 넣으셔면 됩니다. 

```shell
        <Context docBase="IamServiceForder" path="/" reloadable="true"/>
        <Context docBase="alive" path="/alive" reloadable="true"/>
```

## Edit `/app/tomcat/conf/web.xml` -  Error Page 변경(Version 출력 방지)

```shell
    <error-page>
        <location>/error.html</location>
    </error-page>
```

## Edit  `/app/tomcat/bin/setenv.sh` - tuning java heap 
- Memory 1GB시 50% HEAP 설정한 케이스

```shell
export CATALINA_OPTS="$CATALINA_OPTS -Xms256m"
export CATALINA_OPTS="$CATALINA_OPTS -Xmx512m"
export CATALINA_OPTS="$CATALINA_OPTS -XX:MaxPermSize=128m"
```

# Reference
[Official] http://tomcat.apache.org 
