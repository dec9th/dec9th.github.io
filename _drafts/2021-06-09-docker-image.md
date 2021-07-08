---
layout: post
title:  "docker image cheat sheet"
categories: ["docker"]
---


## docker search 

```
$ docker search redis

<output>
NAME                             DESCRIPTION                                     STARS     OFFICIAL   AUTOMATED
redis                            Redis is an open source key-value store that…   9554      [OK]
bitnami/redis                    Bitnami Redis Docker Image                      185                  [OK]
grokzen/redis-cluster            Redis cluster 3.0, 3.2, 4.0, 5.0, 6.0, 6.2      78
...


$ docker search --filter stars=100 redis

<output>
NAME            DESCRIPTION                                     STARS     OFFICIAL   AUTOMATED
redis           Redis is an open source key-value store that…   9554      [OK]
bitnami/redis   Bitnami Redis Docker Image                      185                  [OK]

$ docker search --filter stars=100 --limit 1 redis

<output>
NAME      DESCRIPTION                                     STARS     OFFICIAL   AUTOMATED
redis     Redis is an open source key-value store that…   9554      [OK]
```

보통은 search만 사용합니다. default로 25개 내로 보여주기에 다른 옵션 넣을 케이스가 거의 없습니다.


## docker commit 

```
# 기존 ubuntu image에 env로 변경사항 추가
$ docker run -d -e "SERVER_OWNER=SANTA" --name ubuntu2 ubuntu  /bin/bash
c331deeb1cff04f64ca7bf23b78da3c4503fbd13144e02a81485ecc9307613bc

# Docker image commit 
$ docker commit -m "add env" ubuntu2 ubuntu-bysanta
sha256:8e68ade6e11ce9e8101f30b44481386c89e84b8d3e4762d27d6fef9c2f408996
```

```

파일 생성 후 commit 

touch v1
touch v2


# 기존 ubuntu image에 env로 변경사항 추가
$ docker run -d -e "SERVER_OWNER=SANTA" --name ubuntu2 ubuntu  /bin/bash
c331deeb1cff04f64ca7bf23b78da3c4503fbd13144e02a81485ecc9307613bc

# Docker image commit 
$ docker commit -m "add env" ubuntu2 ubuntu-bysanta
sha256:8e68ade6e11ce9e8101f30b44481386c89e84b8d3e4762d27d6fef9c2f408996
```


## docker image rm / docker rmi

```
$ docker image rm 2dcc641feda7
Deleted: sha256:2dcc641feda7fd148ca92b1a4daa204acf898e6bbd80b3ff48d7ecce6c7ff722
Deleted: sha256:2f6777ac8a5ef02d615f11905d820279db7d9b360f079a4c0ca0cb73e5abf2bf

$ docker rmi ubuntu -f
Untagged: ubuntu:latest
Untagged: ubuntu@sha256:adf73ca014822ad8237623d388cedf4d5346aa72c270c5acc01431cc93e18e2d
Deleted: sha256:7e0aa2d69a153215c790488ed1fcec162015e973e49962d438e18249d16fa9bd
```


## docker save

이미지 저장으로 이미지를 별도 tar 파일로 뺄 때 사용할 수 있습니다.
메타데이터 등 이미지 이름과 태그 등 메타데이터 모두 저장이 됩니다.

```
$ docker save -o redis-docker.tar redis
(별도 output 없음)
```

## docker load

추출해둔 이미지를 복원할 때 사용되는 명령어 입니다.

```
$ docker load  -i redis-docker.tar 
ec5652c3523d: Loading layer [==================================================>]  338.4kB/338.4kB
76d3e24d63f6: Loading layer [==================================================>]  4.194MB/4.194MB
f06719b0aa43: Loading layer [==================================================>]  31.71MB/31.71MB
b896f490f2ed: Loading layer [==================================================>]  2.048kB/2.048kB
e3f4077f577b: Loading layer [==================================================>]  3.584kB/3.584kB
Loaded image: redis:latest
```

## docker export

export 명령은 container를 파일로 백업합니다. image추출과는 다른 점이 단일 container의 volume 자체를 받는다고 보시면 됩니다.
명령인자 값을 image가 아닌 container를 입력합니다.

```
$ docker ps   
CONTAINER ID   IMAGE     COMMAND                  CREATED         STATUS         PORTS                     NAMES
9d84e036eb1d   redis     "docker-entrypoint.s…"   6 minutes ago   Up 6 minutes   0.0.0.0:10892->6379/tcp   gracious_dijkstra

$ docker export -o redis-container.tar 9d84e
```

## docker import

`image`명을 별도로 입력 하지 않으면 아래 `docker images` 처럼 `<none>` 라고 출력됩니다.
container까지 뜨진 않고 image만 (복원)생성됩니다.

```
$ docker import redis-container.tar
sha256:4ad31b3a40140959dd5c4e468df9751c972888edb55ae346c3652572c8b9dca4

$ docker import redis-container.tar redis_own
sha256:5ffe01b9a670b44c7de49680545bdec989ed25d77ab7977724c952dba42319b6

$ docker images
REPOSITORY               TAG       IMAGE ID       CREATED          SIZE
redis_own                latest    5ffe01b9a670   9 seconds ago    102MB
<none>                   <none>    4ad31b3a4014   51 seconds ago   102MB
```

