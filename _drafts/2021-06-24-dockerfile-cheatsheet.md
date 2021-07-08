---
layout: post
title:  "docker file and build cheat sheet" 
categories: ["docker"]
---

# docker build

```
docker build ?????????????????????
```

# docker build --no-cache
git clone 등 `RUN` command는 유사하나 동일 파일명을 쓰는 최신 버전의 파일들이 변경될 경우 cache를 타서 skip되기에 이를 회피하고자 `--no-cache`를 사용할 수 있습니다.
```
docker build --no-cache -t testbuild:0.0 . 
```



# Reference

https://docs.docker.com/engine/reference/builder/
https://docs.docker.com/develop/develop-images/dockerfile_best-practices/
https://12factor.net/ko/

