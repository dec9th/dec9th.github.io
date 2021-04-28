---
layout: post
title:  unable to find "application" callable in file
categories: python
tags: python, uwsgi, error
comments: true
author: santa
---

*Tested all on Amazon linux with AWS Cloud9 IDE*


**uwsgi** 가이드 용으로 Hello world 만 넣고 돌린 `uwsgi`!
아래와 같이 출력 됩니다.  


```
(env) ec2-user:/app/myflask $ uwsgi --http :9090 --wsgi-file run.py 
*** Starting uWSGI 2.0.18 (64bit) on [Fri Jun 21 10:03:11 2019] ***
compiled with version: 4.8.5 20150623 (Red Hat 4.8.5-28) on 20 June 2019 03:21:27
os: Linux-4.14.121-85.96.amzn1.x86_64 #1 SMP Wed May 22 00:45:50 UTC 2019
nodename: ip-172-31-7-89
machine: x86_64
clock source: unix
pcre jit disabled
detected number of CPU cores: 1
current working directory: /app/myflask
detected binary path: /app/myflask/env/bin/uwsgi
*** WARNING: you are running uWSGI without its master process manager ***
your processes number limit is 7892
your memory page size is 4096 bytes
detected max file descriptor number: 4096
lock engine: pthread robust mutexes
thunder lock: disabled (you can enable it with --thunder-lock)
uWSGI http bound on :9090 fd 4
spawned uWSGI http 1 (pid: 5387)
uwsgi socket 0 bound to TCP address 127.0.0.1:39541 (port auto-assigned) fd 3
Python version: 3.6.8 (default, May 24 2019, 18:27:52)  [GCC 4.8.5 20150623 (Red Hat 4.8.5-28)]
*** Python threads support is disabled. You can enable it with --enable-threads ***
Python main interpreter initialized at 0x2710580
your server socket listen backlog is limited to 100 connections
your mercy for graceful operations on workers is 60 seconds
mapped 72920 bytes (71 KB) for 1 cores
*** Operational MODE: single process ***
unable to find "application" callable in file run.py
unable to load app 0 (mountpoint='') (callable not found or import error)
*** no app loaded. going in full dynamic mode ***
*** uWSGI is running in multiple interpreter mode ***
spawned uWSGI worker 1 (and the only) (pid: 5386, cores: 1)
```

깔끔하게 아래와 같이 확인 차 `curl`을 실행했더니 시크하게 `500 Error` 를 발산합니다. 
```
ec2-user:~/environment $ curl localhost:9090 -v
* Rebuilt URL to: localhost:9090/
*   Trying 127.0.0.1...
* TCP_NODELAY set
* Connected to localhost (127.0.0.1) port 9090 (#0)
> GET / HTTP/1.1
> Host: localhost:9090
> User-Agent: curl/7.61.1
> Accept: */*
> 
< HTTP/1.1 500 Internal Server Error
< Connection: close
< Content-Type: text/plain
< 
* Closing connection 0
Internal Server Error
```

직전에 단순 `python run.py` 돌렸을때 굉장히 잘되엇는데....  
실제 서버 시작 간 출력을 다시 살펴보면  
아래와 같은 문구가 있습니다.  
```
unable to find "application" callable in file run.py
unable to load app 0 (mountpoint='') (callable not found or import error)
```

flask 기동시킨 스크립트에 `application`이 선언되는 놈을 찾는 것을 확인 할 수 있습니다.  
예를 들어 아래와 같이 수정했습니다. 
```
# Before
app = Flask(__name__)

# After
application = Flask(__name__)
```

다시 `uwsgi` 실행하고 `curl`로 확인해보면... 
```
ec2-user:~/environment $ curl localhost:9090 -v
* Rebuilt URL to: localhost:9090/
*   Trying 127.0.0.1...
* TCP_NODELAY set
* Connected to localhost (127.0.0.1) port 9090 (#0)
> GET / HTTP/1.1
> Host: localhost:9090
> User-Agent: curl/7.61.1
> Accept: */*
> 
< HTTP/1.1 200 OK
< Content-Type: text/html; charset=utf-8
< Content-Length: 11
< 
* Connection #0 to host localhost left intact
Hello World
```
나이스하게 `200 OK`를 줍니다.  
실제 예전부터 `app`으로 사용했던 것 같은데...
제가 잘못알고 있었겠지 하고 있습니다.

# Reference
https://serverfault.com/questions/412849/uwsgi-cannot-find-application-using-flask-and-virtualenv
