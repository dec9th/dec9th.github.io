---
layout: post
title:  "[알쓸신잡] Amazon linux 2의 extras packages 설치"
categories: 알쓸신잡
tags: nginx amazonlinux2, topic, extratopic
comments: true
---

얼마나 바꼈는지 보려고 yum install php 와 함께 설치테스트를 해보려 했는데 php 5.4.16 버전이 설치되려 하는 것을 보고 그냥 예전 버전 처럼 혼자 신나게 별도 설치해야되나? 하는 자괴감이 들면서 조금 더 찾은 결과에 대해 써보고자 합니다.
실제 이렇게 깊이 알아볼 필요는 없습니다.  그래서 말머리를 **알쓸신잡** 이라고 표기했는데요. 이런 류의 글을 좀 써볼까해서 앞으로도 본 말머리로 찾아뵙고자 합니다.  
알아두기에 쓸데없는 깊이가 불필요하시거나 피로하시다면 글의 제일 하단에는 다른 블로그 글들 처럼 요약본을 두었으니 참고하시면 될 것 같습니다. 
본능적으로 기본이 되는 Official을 좋아하기에... _[Amazon Linux 2 LTS Candidate (2017.12) Release Notes](https://aws.amazon.com/ko/amazon-linux-2/release-notes/) 를 보면 systemd 아래 *extras* 가 있습니다. 

우선 우리가 아는 명령어 부터 `EPEL`과는 분명 다른 `extra`느낌이 옵니다. 실제 명령어 부터 다릅니다. 

아래와 같이 명령시 리스트를 볼 수 있습니다. 
```
$ amazon-linux-extras 
or
$ amazon-linux-extras list
### 아래와 같이 제공가능한 리스트를 출력합니다.  
  0  ansible2   disabled  [ =2.4.2 ]
  1  emacs   disabled  [ =25.3 ]
  2  memcached1.5   disabled  [ =1.5.1 ]
  3  nginx1.12   disabled  [ =1.12.2 ]
  4  postgresql9.6   disabled  [ =9.6.6 ]
  5  python3   disabled  [ =3.6.2 ]
  6  redis4.0   disabled  [ =4.0.5 ]
  7  R3.4   disabled  [ =3.4.3 ]
  8  rust1   disabled  [ =1.22.1 ]
  9  vim   disabled  [ =8.0 ]
 10  golang1.9   disabled  [ =1.9.2 ]
 11  ruby2.4   disabled  [ =2.4.2 ]
 12  nano   disabled  [ =2.9.1 ]
 13  php7.2   disabled  [ =7.2.0 ]
 14  lamp-mariadb10.2-php7.2   disabled  [ =10.2.10_7.2.0 ]
```

아마도 위 그림대로라면 우리가 보통 부르는 패키지 혹은 서비스 명을 `Topic` 이라고 명명하고 있습니다. 
**Redis Topic**을 활성화(enable) 시켜보겠습니다.  *Topic*은 단순 `redis`라고 기입하지말고 `redis4.0` 이라는 전체 *Topic Name*을 써주셔야 합니다.

```
$ amazon-linux-extras enable redis4.0
  0  ansible2   disabled  [ =2.4.2 ]
  1  emacs   disabled  [ =25.3 ]
  2  memcached1.5   disabled  [ =1.5.1 ]
  3  nginx1.12   disabled  [ =1.12.2 ]
  4  postgresql9.6   disabled  [ =9.6.6 ]
  5  python3   disabled  [ =3.6.2 ]
  6  redis4.0=latest  enabled  [ =4.0.5 ]
  7  R3.4   disabled  [ =3.4.3 ]
  8  rust1   disabled  [ =1.22.1 ]
  9  vim   disabled  [ =8.0 ]
 10  golang1.9   disabled  [ =1.9.2 ]
 11  ruby2.4   disabled  [ =2.4.2 ]
 12  nano   disabled  [ =2.9.1 ]
 13  php7.2   disabled  [ =7.2.0 ]
 14  lamp-mariadb10.2-php7.2   disabled  [ =10.2.10_7.2.0 ]
```

위 6번의 Redis부분을 보면 다른 부분과 다르게 `latest` 표시 및 `enable` 이라고 활성화된 모습을 볼 수 있습니다. 

이후 실제 설치는 `yum install redis`로 하셔도 좋습니다. 

그 외 설치 방법으로 아래와 같이 `install` 옵션을 주고 실행하는 방법도 있습니다. 

```
$ amazon-linux-extras install redis4.0
  0  ansible2   disabled  [ =2.4.2 ]
  1  emacs   disabled  [ =25.3 ]
  2  memcached1.5   disabled  [ =1.5.1 ]
  3  nginx1.12   disabled  [ =1.12.2 ]
  4  postgresql9.6   disabled  [ =9.6.6 ]
  5  python3   disabled  [ =3.6.2 ]
  6  redis4.0=latest  enabled  [ =4.0.5 ]
  7  R3.4   disabled  [ =3.4.3 ]
  8  rust1   disabled  [ =1.22.1 ]
  9  vim   disabled  [ =8.0 ]
 10  golang1.9   disabled  [ =1.9.2 ]
 11  ruby2.4   disabled  [ =2.4.2 ]
 12  nano   disabled  [ =2.9.1 ]
 13  php7.2   disabled  [ =7.2.0 ]
 14  lamp-mariadb10.2-php7.2   disabled  [ =10.2.10_7.2.0 ]
```

그러나 뭐가 잘 설치되었는지는 위 출력 건으로는 확인이 불가합니다. 

실제 아래와 같이 `yum.log` 혹은 `messages` 로그를 통해 확인 가능합니다. 

```
$ tail /var/log/yum.log
... 
Feb 09 07:01:20 Installed: redis-4.0.5-1.amzn2.0.1.x86_64
```

실제 레포 구성은 아래와 같이 되어 있습니다. 아래 파일은 `redis4.0`과 `php7.2` topic을 활성화 시킨 상태입니다. 
이로써 알수 있는 점은 우리가 알고 있는 epel과 달리 활성화 시킬수록 각 개별적인 topic 단위로 config가 추가되며 AWS에서 Topic단위 관리를 하는구나 정도 유추 해볼 수 있습니다.

```
$ cat /etc/yum.repos.d/amzn2-extras.repo
...
[amzn2extra-redis4.0-source]
enabled = 0
name = Amazon Extras source repo for redis4.0
mirrorlist = http://amazonlinux.$awsregion.$awsdomain/$releasever/extras/redis4.0/latest/SRPMS/mirror.list
gpgcheck = 1
priority = 10

[amzn2extra-redis4.0-debuginfo]
enabled = 0
name = Amazon Extras debuginfo repo for redis4.0
mirrorlist = http://amazonlinux.$awsregion.$awsdomain/$releasever/extras/redis4.0/latest/debuginfo/$basearch/mirror.list
gpgcheck = 1
priority = 10

[amzn2extra-redis4.0]
enabled = 1
name = Amazon Extras repo for redis4.0
mirrorlist = http://amazonlinux.$awsregion.$awsdomain/$releasever/extras/redis4.0/latest/$basearch/mirror.list
gpgcheck = 1
priority = 10

[amzn2extra-php7.2-source]
enabled = 0
name = Amazon Extras source repo for php7.2
mirrorlist = http://amazonlinux.$awsregion.$awsdomain/$releasever/extras/php7.2/latest/SRPMS/mirror.list
gpgcheck = 1
priority = 10

[amzn2extra-php7.2-debuginfo]
enabled = 0
name = Amazon Extras debuginfo repo for php7.2
mirrorlist = http://amazonlinux.$awsregion.$awsdomain/$releasever/extras/php7.2/latest/debuginfo/$basearch/mirror.list
gpgcheck = 1
priority = 10

[amzn2extra-php7.2]
enabled = 1
name = Amazon Extras repo for php7.2
mirrorlist = http://amazonlinux.$awsregion.$awsdomain/$releasever/extras/php7.2/latest/$basearch/mirror.list
gpgcheck = 1
priority = 10
```

또한 정석적인 방법인 `yum repolist` 로도 확인 가능합니다. 

```
$ yum repolist
Loaded plugins: langpacks, priorities, update-motd
repo id                                           repo name                                      status
amzn2-core/2017.12/x86_64                         Amazon Linux 2 core repository                 7,226
amzn2extra-php7.2/2017.12/x86_64                  Amazon Extras repo for php7.2                     56
amzn2extra-redis4.0/2017.12/x86_64                Amazon Extras repo for redis4.0                    4
repolist: 7,286
```

본 글 제목의 말머리가 “알쓸신잡"인 만큼 쓸데 없지만 한 티어 더 들어가보겠습니다. 
**어떤 패키지들을 가지고 있을까?** 에 궁금증이 생겨서... mirrorlist의 경우 찾아서 들어가보시면 아마도 암호화처리한 hash된 데이터 출력이 될텐데요 해당 명령어는 뭘로 만들었을까하고 아래와 같이 파일 속성 검색 시 shell script로 출력이 됩니다. 
```
$ file $(which amazon-linux-extras)
```

역시나 해당 파일을 열어서 제일 하단에 보면 아래와 같이 python module 실행한 것으로 확인됩니다.  

```
py=$(command -v python)
exec env PYTHONIOENCODING=UTF-8 $py -m amazon_linux_extras "$@"
```

보통 모듈들은 `/usr/lib/python2.7/site-packages`에 설치 됩니다. 
실제 그 하위에서 `/usr/lib/python2.7/site-packages/amazon_linux_extras/cli.py` 를 찾았는데요

해당 파일을 열어 보시면 아래와 같이 `CATALOG_URL` 을 확인할 수 있습니다. 

```
$ grep http  /usr/lib/python2.7/site-packages/amazon_linux_extras/cli.py 
...
CATALOG_URL = os.environ.get("CATALOGURL", "http://amazonlinux.{awsregion}.{awsdomain}/{releasever}/extras-catalog.json")
...
```
 
안의 변수들은 `cli.py`를 열어보면 어렵잖게 검색을 통해 찾아볼 수 있으니 설명은 하지 않겠습니다. 

목록은 아래와 같이 확이 가능합니다. `n`은 topic name, `inst`는 설치 가능한 package들인데 code 내에서는 `reconmendations`로 표기되는 것 같습니다. 

```
curl http://amazonlinux.ap-northeast-2.amazonaws.com/2017.12/extras-catalog.json
{"motd": "", "status": "ok", "version": 1, "whitelists": [[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]], "topics": [
        {"n": "ansible2", "inst": ["ansible"], "versions": ["2.4.2"]},
        {"n": "emacs", "inst": ["emacs"], "versions": ["25.3"]},
        {"n": "memcached1.5", "inst": ["memcached"], "versions": ["1.5.1"], "visible": ["memcached", "memcached-devel"]},
        {"n": "nginx1.12", "inst": ["nginx"], "versions": ["1.12.2"]},
        {"n": "postgresql9.6", "inst": ["postgresql"], "versions": ["9.6.6"]},
        {"n": "python3", "inst": ["python3", "python3-pip", "python3-setuptools", "python3-wheel"], "versions": ["3.6.2"]},
        {"n": "redis4.0", "inst": ["redis"], "versions": ["4.0.5"]},
        {"n": "R3.4", "inst": ["R"], "versions": ["3.4.3"]},
        {"n": "rust1", "inst": ["rust", "cargo"], "versions": ["1.22.1"]},
        {"n": "vim", "inst": ["vim-enhanced", "vim-minimal"], "versions": ["8.0"]},
        {"n": "golang1.9", "inst": ["golang"], "versions": ["1.9.2"]},
        {"n": "ruby2.4", "inst": ["ruby", "ruby-irb", "rubygem-rake", "rubygem-json", "rubygems"], "versions": ["2.4.2"]},
        {"n": "nano", "inst": ["nano"], "versions": ["2.9.1"]},
        {"n": "php7.2", "inst": ["php-cli", "php-pdo", "php-fpm", "php-json", "php-mysqlnd"], "versions": ["7.2.0"]},
        {"n": "lamp-mariadb10.2-php7.2", "inst": ["php-cli", "php-pdo", "php-fpm", "php-json", "php-mysqlnd", "mariadb"], "versions": ["10.2.10_7.2.0"]}
]}
```

> 실제 위와 같이 확인하시기 보다는 `amazon-linux-extras info` 명령어를 쓰시는 것이 편합니다. 


# Quick Guide 

*마지막으로 간략히 정리하자면* 

- extras topic 목록 확인 

```
$ amazon-linux-extras list
```

- extras topic 설치 가능토록 활성화

```
$ amazon-linux-extras enable
```

- extras topic 설치 불가하도록 비활성화

```
$ amazon-linux-extras disable
```

- extras topic 내 패키지 목록 확인 (예: redis4.0)

```
$ amazon-linux-extras info redis4.0
```

- extras topic 설치 (예: redis4.0)

```
$ amazon-linux-extras install redis4.0
```

이상 알쓸신잡 Amazon Linux 2 에서 extras 설치 방법입니다.
 
# Reference
https://aws.amazon.com/ko/amazon-linux-2/release-notes/
https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/amazon-linux-ami-basics.html
https://dev.classmethod.jp/cloud/aws/how-to-work-with-amazon-linux2-amazon-linux-extras/
https://docs.aws.amazon.com/ko_kr/AWSEC2/latest/UserGuide/ec2-lamp-amazon-linux-2.html
