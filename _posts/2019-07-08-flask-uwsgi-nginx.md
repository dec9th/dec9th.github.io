---
layout: post
title:  "Nginx, uwsgi 를 이용한 flask Web service"
author: santa
categories: ["python, nginx, uwsgi, flask, web"]
featured-img: logo-python
---


`Nginx`와 함께 Python의 `flask`, `uwsgi`를 이용한 웹 서버 구성을 해보고자 합니다.  
AWS CLOUD9를 사용하다보니 Amazon Linux 에서 테스트 되었으며 CentOS6(RHEL6)와 호환됨을 미리 알려드립니다.


# flask + uwsgi 서버 구성

## Install Python  
우선 python 및 pip 설치를 위해 아래와 같이 입력 합니다. 
```
yum -y install python3 python3-devel python3-pip gcc pcre-devel
```

위 package 중 
- `gcc`는 `pip`에서 `python` 패키지 빌드간 필요 합니다.
- `pcre-devel`은 `uwsgi` 에서 필요로 합니다. 없을 경우 `uwsgi` 실행 시 에러 출력됩니다. 

## Create project directory  

프로젝트 용으로 사용할 디렉토리 생성합니다. 홈 디렉토리 사용하셔도 무방합니다.

```
mkdir -pv /app/myflask
cd  /app/myflask
```

## Create virtualenv

본 프로젝트를 위한 가상환경을 구성합니다.  

```
virtualenv env
source env/bin/activate
```

이제부터 `(env)` 라는 표시와 함께 `prompt`가 변경과 함께 독자적인 환경으로 변경됩니다.

> 실제 `env` 디렉토리 내 모든 세팅이 이루어지기에 본 디렉토리만 지우면 다시 깔끔한 서버가 됩니다.

## Install flask and uwsgi

`flask`와 `uwsgi`를 설치합니다. `uwsgi`의 경우 `deactivate`한 이후에 설치하셔도 나이스 합니다.  

```
pip3 install flask uwsgi 
```

## Create a app

`/app/myflask/run.py`로 파일을 생성하여 아래와 같이 간단한 `flask` 모듈을 얹은 스크립트를 작성합니다. 

```
from flask import Flask

app = Flask(__name__)

@app.route('/')
def index():
    return "Hi mate!"

if __name__ == '__main__':
    app.run()
```

## Test

위 코드를 가볍게 python에서 잘 구동되는지 테스트 합니다.  
`Hi mate!` 가 출력되면 정상입니다.

```
# run server
python app.py

# Check (Default Port : 5000)
curl localhost:5000

# output
Hi mate!
```

단순 `python` 실행 시 잘 되는 것 확인했고...  
이제 `uwsgi`를 이용해 테스트 해봅니다.  그냥 실행하면 창을 못 쓸 수 있으니 `background(&)` 로 실행합니다.

```
uwsgi --http :9090 --wsgi-file run.py &
```

에러가 없다면 이전에 사용했던 `curl` 명령을 하면 동일 결과를 얻으실 겁니다. 


## uwsgi 파일 설정 

일단 `uwsgi`가 잘 동작하는 것은 확인 했으니 `uwsgi.ini` 파일을 만들어봅시다. 

- 경로 : /app/myflask/uwsgi.ini

```
[uwsgi]

module = run:app
chdir=/app/myflask
virtualenv = /app/myflask/env

master = true
processes = %k

uid = nginx
gid = nginx


socket = run.sock
chmod-socket = 660

die-on-term = true
vacuum = true
```

다른 것들 보다 vaccum과 processes를 조금 첨언하자면  
`vaccum`의 경우 지울 때 `socket` 파일 삭제를 수행합니다.

processes엔 보통 숫자를 기재하여 원하는 만큼의 process를 띄울 수 있는데요.  
`%k` 변수를 통해 실제 CPU core수 만큼 자동 기재되도록 설정하였습니다.  

그리고 module의 경우 `run:app` 으로 표기했는데요.  
code 내 `Flask(__name__)`를 `application`으로 하였다면 default로 `application`을 찾기에 변경 혹은 제거 하시면 됩니다.


`socket`의 경우 `http`가 아닌 `unix socket`을 이용하면 이점으로 local 통신 간 `tcp(or http)`를 사용할 경우 과도한 `time_wait` 및 불필요하게 `socket` 낭비가 초래 됩니다.  
그 외에 굳이 **3&4 hand shake**가 발생하며 그로 인한 **interrupt, context switch**가 더 발생하게 됩니다.  

`/etc/init/uwsgi.conf` 파일을 만들어 upstart 스크립트를 작성합니다.  
`env`를 이용해 `uwsgi`를 설치하였기에 아래와 같이 *full path*를 기재해주셔야 합니다. 

만사 귀찮은 분들을 위해 굳이 단순하게 정리를 하자면

- `processes` : 모르면 꼭 **core**수 만큼 넣자
- `uid`, `gid` : 보안 신경 쓴다는 차원에서 **root**는 피하자 (그래도 짜치면 패스하자, 털리면 요단강)
- `socket` : 모르면 모를 수록 **unix socket** 쓰자 (운영 중에 굳이 http로 갔다가 이슈보는 분들 많이 봄)
- `vaccum` : 모르면 모를 수록 그냥 넣자 (운영중에 없어서 짜치는 경우 발생 시 주위의 레이저 예고)


## upstart script 생성

`/etc/init/uwsgi.conf` 파일을 생성하여 아래와 같이 입력합니다.

```
# simple uWSGI script

description "uwsgi tiny instance"
start on runlevel [2345]
stop on runlevel [06]

respawn

script
    cd /app/myflask
    source env/bin/activate
    uwsgi --ini uwsgi.ini
end script
```

> `uwsgi` 설치시 `virtualenv`를 `activate` 하지 않고 그냥 global하게 설치하셔서 사용하실 경우엔 `source` 굳이 안하셔도 됩니다. 


## upstart 시작 

```
start uwsgi
```

*upstart 제어 방법*

- `start` daemon : daemon 시작
- `stop` daemon : daemon 중지
- `status` daemon : daemon 상태 체크

이로써 python부분은 모두 완료가 되고 이제 `nginx`와 붙이는 작업을 합니다.

# Nginx 구성
`nginx` 는 설치 이후에 가볍게 `/` 로 유입되는 모든 Request 에 대해 flask로 Traffic을 보낼겁니다.

## Nginx 설치
```
yun -y install nginx

```

## Nginx 설정 변경
`/etc/nginx/nginx.conf` 내 아래와 같이 `/` 모든 트래픽이 uwsgi로 흐를 수 있게 설정합니다. 
```
...
        location / {
                include uwsgi_params;
                uwsgi_pass unix:/app/myflask/run.sock;
        }
...
```

## Nginx 시작
```
service nginx restart
```

# Issue
uwsgi 서버 실행 간 아래와 같은 에러 발생 시 테스트 해보면 500 error 가 발생 한다 
```
!!! no internal routing support, rebuild with pcre support !!!

```
아래와 같이 충분히 해결 가능 합니다. 
```
yum install pcre-devel
```
 
# Reference

https://www.digitalocean.com/community/tutorials/how-to-serve-flask-applications-with-uwsgi-and-nginx-on-centos-7

https://medium.com/ymedialabs-innovation/deploy-flask-app-with-nginx-using-gunicorn-and-supervisor-d7a93aa07c18

https://www.digitalocean.com/community/tutorials/how-to-set-up-uwsgi-and-nginx-to-serve-python-apps-on-ubuntu-14-04

https://uwsgi-docs.readthedocs.io/

https://uwsgi-docs.readthedocs.io/en/latest/Options.html

https://uwsgi-docs.readthedocs.io/en/latest/Upstart.html

https://uwsgi-docs.readthedocs.io/en/latest/Systemd.html

https://uwsgi-docs.readthedocs.io/en/latest/Configuration.html

