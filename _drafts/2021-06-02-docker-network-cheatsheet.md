---
layout: post
title:  "docker network cheat sheet"
categories: ["docker"]
---

## docker network ls 

```
$ docker network ls

<output>
NETWORK ID     NAME      DRIVER    SCOPE
d93156bea1d4   bridge    bridge    local
7eb064683b9e   host      host      local
13e7734e771e   none      null      local
```

## docker network inspect 

```
docker network inspect bridge
[
    {
        "Name": "bridge",
        "Id": "d93156bea1d4d03bbf7356f9e50bbe7f880ce33552e8e52dcc1ba24ed5348c49",
        "Created": "2021-06-08T01:48:12.1013952Z",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.17.0.0/16",
                    "Gateway": "172.17.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {
            "ea9effe70ed78886a853e5ceee26f5f6ae99aca4a7ec69838f79cb3831f3462d": {
                "Name": "cool_feistel",
                "EndpointID": "ba890adb170ba961b5e8ea97ee50209d5fed1a5192aee77686040d7a38741b02",
                "MacAddress": "02:42:ac:11:00:02",
                "IPv4Address": "172.17.0.2/16",
                "IPv6Address": ""
            }
        },
        "Options": {
            "com.docker.network.bridge.default_bridge": "true",
            "com.docker.network.bridge.enable_icc": "true",
            "com.docker.network.bridge.enable_ip_masquerade": "true",
            "com.docker.network.bridge.host_binding_ipv4": "0.0.0.0",
            "com.docker.network.bridge.name": "docker0",
            "com.docker.network.driver.mtu": "1500"
        },
        "Labels": {}
    }
]


$ docker ps -a
CONTAINER ID   IMAGE                        COMMAND                  CREATED          STATUS                      PORTS                                       NAMES
ea9effe70ed7   redis                        "docker-entrypoint.s…"   15 minutes ago   Up 15 minutes               0.0.0.0:6379->6379/tcp, :::6379->6379/tcp   cool_feistel
```



> inspect 출력 시 `Containers` 내에 `cool_feistel`라는 이름의 container를 볼수 있습니다. 
> 즉, 본 container는 `bridge`를 사용하고 있습니다.

## docker network create --driver bridge 

```
$ docker network create -d bridge bridge01

<output>
7e1110ec078bccee6da94d81f34064f1bdb1588d1ea8e7666329081e8a296514
```
`--driver bridge` 옵션을 빼도 기본 값으로 `bridge`로 생성 됩니다.


```
$ docker network create \
  --driver=bridge \
  --subnet=172.30.0.0/16 \
  --ip-range=172.30.1.0/24 \
  --gateway=172.30.1.254 \
  br30

<output>
20d0cb4ddbacab44739ac2d09024f4e8665bb2bc3ad48c3b44bba98bf49d4844

$ docker run -it --name network-test --net br30 ubuntu /bin/bash
root@86b198e89e6b:/# ifconfig
eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 172.30.1.0  netmask 255.255.0.0  broadcast 172.30.255.255
```

br30이라는 bridge를 만들고 이후 container의 network역시 지정하여 생성합니다.
ifconfig로 ip 확인 시 새로 생성한 172.30.1.x의 IP가 할당된 것을 확인할 수 있습니다. 
network 생성 시 `--ip-range`를 포함하여 172.30.0.0이 아닌 172.30.1.0 내 IP를 할당 받은 것을 확인할 수 있습니다.


## --network host 

```
$ docker run -it --name network-host --net host ubuntu /bin/bash
root@docker-desktop:/# 
```

위와 같이 hostname부터 다릅니다. `ifconfig` 를 실행해보면 `eth`, `veth`, `docker0`, 이전에 만든 `br` 들까지 모두 확인 가능합니다.

## --network none 

```
docker run -it --name network-none --net none ubuntu /bin/bash
```

`lo` 하나만 있고 외부로 통신이 불가하며 apt-get도 당연히 안됩니다.