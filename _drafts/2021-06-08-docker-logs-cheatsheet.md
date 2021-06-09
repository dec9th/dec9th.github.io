---
layout: post
title:  "docker logs cheat sheet"
categories: ["docker"]
---

## docker logs

`-n`, `--tail` 몇 줄만 뽑을 때 사용

```
$ docker logs cool_feistel --tail 5

<output>
1:M 08 Jun 2021 10:31:40.741 * monotonic clock: POSIX clock_gettime
1:M 08 Jun 2021 10:31:40.741 * Running mode=standalone, port=6379.
1:M 08 Jun 2021 10:31:40.741 # Server initialized
1:M 08 Jun 2021 10:31:40.741 # WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.
1:M 08 Jun 2021 10:31:40.742 * Ready to accept connections
```


`-f`, `--follow` tail -f와 같이 계속 대기하며 로그를 출력합니다. `--tail`을 붙이면 리눅스에서와 동일하게 몇줄 출력을 시작으로 지속적으로 출력 됩니다. `-t`는 timestamp 입니다.
```
docker logs cool_feistel --tail 1 -f -t
2021-06-08T10:31:40.742375500Z 1:M 08 Jun 2021 10:31:40.742 * Ready to accept connections
```

`--since`와 `--until`을 통해 범위를 잡아 로그를 검색할 수 있습니다. 
```
docker logs cool_feistel --since 10m --until 2m --tail 1 -t
2021-06-08T10:31:40.742375500Z 1:M 08 Jun 2021 10:31:40.742 * Ready to accept connections
```

아래와 같이 `inspect`를 통해 file로그 위치를 찾을 수 있습니다.
```
docker container inspect ea9effe70ed7  | find "log"
        "LogPath": "/var/lib/docker/containers/ea9effe70ed78886a853e5ceee26f5f6ae99aca4a7ec69838f79cb3831f3462d/ea9effe70ed78886a853e5ceee26f5f6ae99aca4a7ec69838f79cb3831f3462d-json.log",
```

## option
- `--details` : Show extra details provided to logs
- `--follow`, `-f` : Follow log output
- `--tail`, `-n` : Number of lines to show from the end of the logs
- `--timestamps` , `-t` : Show timestamps
- `--since` : Show logs since timestamp (e.g. 2013-01-02T13:23:37Z) or relative (e.g. 42m for 42 minutes)
- `--until` : Show logs before a timestamp (e.g. 2013-01-02T13:23:37Z) or relative (e.g. 42m for 42 minutes)
