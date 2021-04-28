---
layout: post
title:  "How to install Nginx on Amazon linux 2"
categories: nginx
tags: nginx amazonlinux2
comments: true
---

*Tested all on Amazon Linux 2*

# Overview

작년 연말에 출시된 AWS의 `Amazon linux 2` 에 `nginx`를 설치하고자 합니다. 실제 `RHEL7`과 유사하기에 서비스 명령어 정도 차이가 있습니다.
그 외 현재 `AWS repo` 내 `nginx`를 검색이 안 되기에 아래와 같이 예전 블로그 방식으로 `Nginx`에서 가이드하는 `Repo` 설정부터 하시면 큰 어려움 없이 설치 가능합니다.

# Installation

## 1. Add repo
```shell
$ echo '[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/centos/7/$basearch/
gpgcheck=0
enabled=1' | tee  /etc/yum.repos.d/nginx.repo
```

## 2. Install Package from Repo

```shell
$ yum -y install nginx
     # or (실패시 repo내 패키지 확인 후 ... 아래는 RHEL6 버전이니 설치간 7 및 세부 버전 변경 필요)
     # rpm -vih http://nginx.org/packages/centos/7/x86_64/RPMS/nginx-1.10.1-1.el6.ngx.x86_64.rpm
```

# Operation

유의 사항으로 systemctl `start`, `stop` 시 예전 처럼 *OK* 같은 출력이 없습니다.  `status` 및 여러 경험에 우러나오는 명령어로 확인하셔야 합니다. 

* start service

```shell
$ systemctl start nginx
```

* stop service

```shell
$ systemctl stop nginx 
```

* check the service - service

```shell
$ systemctl status nginx

### output as below
● nginx.service - nginx - high performance web server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Fri 2018-02-02 06:23:12 UTC; 29min ago
     Docs: http://nginx.org/en/docs/
  Process: 3072 ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx.conf (code=exited, status=0/SUCCESS)
  Process: 3069 ExecStartPre=/usr/sbin/nginx -t -c /etc/nginx/nginx.conf (code=exited, status=0/SUCCESS)
 Main PID: 3073 (nginx)
   CGroup: /system.slice/nginx.service
           ├─3073 nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx.conf
           └─3074 nginx: worker process
```

* check the service - process

```shell
$ ps -ef | grep nginx

### output as below
root      3302     1  0 06:54 ?        00:00:00 nginx: master process /usr/sbin/nginx -c /etc/nginx/nginx.conf
nginx     3303  3302  0 06:54 ?        00:00:00 nginx: worker process
```

* check the service - netstat

```shell
$ netstat -anpt | grep nginx

### output as below
tcp        0      0 0.0.0.0:80              0.0.0.0:*               LISTEN      3302/nginx: master   off (0.00/0/0)
```

* check the service - curl

```shell
$ echo "By santa" | tee /usr/share/nginx/html/alive.txt
$ curl localhost/alive.txt
# you can see "by santa"
```

# Reference

[Official] http://nginx.org/en/linux_packages.html#stable

