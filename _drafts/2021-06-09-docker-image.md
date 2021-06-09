---
layout: post
title:  "docker image cheat sheet"
categories: ["docker"]
---


# cheatsheet

```
$ docker search redis

```

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


파일 생성 후 commit 

touch v1
touch v1