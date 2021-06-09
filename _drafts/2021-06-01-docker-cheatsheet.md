---
layout: post
title:  "docker cheat sheet"
categories: ["docker"]
---

## docker version check
```
$ docker -v

<output>
Docker version 20.10.6, build 370c289
```


## docker run
```
$ docker run -it ubuntu

<output>
root@df19a6804a79:/# ls
```
옵션 설명
- `-i` : interactive
- `-t` : tty

docker run은 아래 명령을 수반합니다. (생략 역시 가능)
- `docker pull` : container 이미지를 가져옵니다.(기본:docker hub)
- `docker create` : container 생성만 합니다.
- `docker start` : container 를 시작합니다. 
- `docker attach` : container 내 접속합니다.


컨테이너 정지하지 않고 빠져 나올거라면 CTRL+P,Q를 입력하면 됩니다.


## docker run with port
```
$ docker run -i -t -dp 6379:6379 redis

<output>
Unable to find image 'redis:latest' locally
latest: Pulling from library/redis
69692152171a: Pull complete
a4a46f2fd7e0: Pull complete
bcdf6fddc3bd: Pull complete
2902e41faefa: Pull complete
df3e1d63cdb1: Pull complete
fa57f005a60d: Pull complete
Digest: sha256:7e2c6181ad5c425443b56c7c73a9cd6df24a122345847d1ea9bb86a5afc76325
Status: Downloaded newer image for redis:latest
054b9bc56938a2501be3bf12db0ca2de7fe349d15e262a139b2ad17645bdea09
```


## docker pull 
```
docker pull ubuntu

<output>
Using default tag: latest
latest: Pulling from library/ubuntu
345e3491a907: Pull complete
57671312ef6f: Pull complete
5e9250ddb7d0: Pull complete
Digest: sha256:adf73ca014822ad8237623d388cedf4d5346aa72c270c5acc01431cc93e18e2d
Status: Downloaded newer image for ubuntu:latest
docker.io/library/ubuntu:latest
```



## docker create

```
$ docker create ubuntu

<output>
Unable to find image 'ubuntu:latest' locally
latest: Pulling from library/ubuntu
345e3491a907: Pull complete
57671312ef6f: Pull complete
5e9250ddb7d0: Pull complete
Digest: sha256:adf73ca014822ad8237623d388cedf4d5346aa72c270c5acc01431cc93e18e2d
Status: Downloaded newer image for ubuntu:latest
baf2ae29717cd7888b23e237be7b6ad8155852a2d0ae83fa373d8bdfecedcf7a
```


## docker start
```
$ docker start cc865167e54b
cc865167e54b
```


## docker stop

```
$ docker stop df19a6804a79

<output>
df19a6804a79
```


## docker ps

ps 명령은 현재 실행 중인 container만 출력하며 `-a` 옵션을 포함하면 전체 출력됩니다.

```
docker ps

<output>
CONTAINER ID   IMAGE     COMMAND                  CREATED       STATUS          PORTS                                       NAMES
cc865167e54b   redis     "docker-entrypoint.s…"   3 hours ago   Up 40 minutes   0.0.0.0:6379->6379/tcp, :::6379->6379/tcp   epic_wiles

$docker ps -a

<output>
CONTAINER ID   IMAGE                           COMMAND                  CREATED          STATUS                     PORTS                                       NAMES
df19a6804a79   ubuntu                          "/bin/bash"              3 minutes ago    Exited (0) 7 seconds ago                                               naughty_haibt
054b9bc56938   redis                           "docker-entrypoint.s…"   14 minutes ago   Up 14 minutes              0.0.0.0:6379->6379/tcp, :::6379->6379/tcp   quirky_heisenberg
e8536c975567   docker/getting-started:latest   "/docker-entrypoint.…"   2 weeks ago      Exited (255) 13 days ago   80/tcp                                      nice_neumann
ce20cff225ca   dec9th/jekyll-theme:latest      "/usr/jekyll/bin/ent…"   2 weeks ago      Exited (255) 2 weeks ago   0.0.0.0:4000->4000/tcp, 35729/tcp           findicator
```

## docker rm 

`stop`과 output이 동일 합니다.
```
docker rm -f df19a6804a79

<output>
df19a6804a79
```
`-f` : running 중인 Container도 강제 종료하고 삭제합니다.


## docker image ls

```
$ docker image ls
or
$ docker images

<output>
REPOSITORY               TAG       IMAGE ID       CREATED        SIZE
redis                    latest    fad0ee7e917a   5 days ago     105MB
dec9th/jekyll-theme      latest    056608d56550   2 weeks ago    953MB
ubuntu                   latest    7e0aa2d69a15   6 weeks ago    72.7MB
docker/getting-started   latest    3ba8f2ff0727   2 months ago   27.9MB
```

## docker image rm

- `image name`으로 하면 아래와 같이 에러가 출력되며 `container name` 혹은 `container id` 여야한다.
```
$ docker image rm ubuntu

<output>
Error response from daemon: conflict: unable to remove repository reference "ubuntu" (must force) - container df19a6804a79 is using its referenced image 7e0aa2d69a15

$ docker image rm 7e0aa2d69a15

<output>
Untagged: ubuntu:latest
Untagged: ubuntu@sha256:adf73ca014822ad8237623d388cedf4d5346aa72c270c5acc01431cc93e18e2d
Deleted: sha256:7e0aa2d69a153215c790488ed1fcec162015e973e49962d438e18249d16fa9bd
Deleted: sha256:3dd8c8d4fd5b59d543c8f75a67cdfaab30aef5a6d99aea3fe74d8cc69d4e7bf2
Deleted: sha256:8d8dceacec7085abcab1f93ac1128765bc6cf0caac334c821e01546bd96eb741
Deleted: sha256:ccdbb80308cc5ef43b605ac28fac29c6a597f89f5a169bbedbb8dec29c987439
```


## docker port (port check)

port를 확인하기 위해서는 `NAME` 을 입력해야 합니다.

```
$ docker port epic_wiles

<output>
6379/tcp -> 0.0.0.0:6379
6379/tcp -> :::6379
```

## docker inspect 

Spec과 관련된 상세 정보와 CPU 사용량, 등 성능 지표 포함 json format으로 출력 됩니다.
```
$ docker inspect cc865167e54b

<output>
...
"Id": "cc865167e54b396d0727cb51dc50a4ae46b7968aa2ff79081d4a7357a8594e8e",
...
```


## docker rename 

```
$ docker rename epic_wiles my_redis

<null>
```


## docker exec

```
docker exec -i -t my_redis /bin/bash
root@cc865167e54b:/data# ls

<output>
dump.rdb
```


## docker run -e 

`-e` 옵션을 주면 환경변수를 적용 할 수 있습니다.

```
docker run -it -e "SERVER_OWNER=SANTA" ubuntu  /bin/bash
root@f98ae3742d49:/# echo $SERVER_OWNER

<output>
SANTA
```


## docker run -v 

```
$ docker run -dp 16379:6379 -v o:\redis\:/var/lib/redis --name dump_redis redis # windows 
$ docker run -dp 16379:6379 -v /docker_vol/data:/data --name dump_redis redis # linux


# redis 내 data 적재 후 해당 디렉토리에서 확인하면 됩니다.(dump.rdb)
$ docker exec dump_redis redis-cli save
```

`-v` 옵션을 주면 호스트(OS) Volume을 붙일 수 있습니다.
`-p` 옵션과 동일하게 여러 `-v`를 여러번 입력하며 여러 volume을 붙일 수 있습니다. 
단일 파일과 매핑도 가능합니다. 예를 들면 호스트 측 `/docker_vol/dump.rdb`와 container 측 `/data/dump.rdb`와 매핑 역시 가능합니다.

방식은 당연히 `mount` 형태와 유사합니다. 기존에 파일을 무시하고 호스트 측 파일을 우선 시 합니다.


## docker volume 

```
$ docker volume create --name volume1

<output>
volume1

$ docker volume ls

<output>
DRIVER    VOLUME NAME
...
local     volume1


$ docker run -dp 26379:6379 -v volume1:/data --name redis_dockervol redis

<output>
af29de38c9a1b5f5664a82d4f36244b04ef89ff97a88e2b62f6b629843691ce9

$ docker  inspect  redis_dockervol  | grep "volume1"
                "volume1:/data"
                "Name": "volume1",
                "Source": "/var/lib/docker/volumes/volume1/_data",

```

본 명령들은 볼륨 생성 / container 실행 / 실제 volume 위치를 확인하는 과정을 출력합니다.
