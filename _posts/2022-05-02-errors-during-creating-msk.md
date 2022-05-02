---
layout: post
title:  "MSK 재설정 간 각종 에러들"
categories: ["msk"]
---


# Broker node를 줄이는 것은 불가하다.
 - 4개 에서 3개로 줄일 때 발생한 로그
```
╷
│ Error: error updating MSK Cluster (arn:aws:kafka:ap-northeast-2:012345678910:cluster/my-msk-weapne2/1c2a0c6a-b411-45bc-9056-2b395a46e740-2) broker count: BadRequestException: The number of broker nodes cannot be reduced.
│ {
│   RespMetadata: {
│     StatusCode: 400,
│     RequestID: "4edbd69f-4aee-4dad-a900-b7328dee6748"
│   },
│   InvalidParameter: "targetNumberOfBrokerNodes",
│   Message_: "The number of broker nodes cannot be reduced."
│ }
│
```

# Broker node 수량은 설정한 subnet의 곱절로 추가가 가능하다.
- 보통 zookeeper 때문에 3개로 하는데 개발은 1,2 개로 설정해줘도 좋다.
- production의 경우 역시나 기본 kafka official 등 zookeeper 설치시 3개의 서버를 요하기 때문에 3중화를 기본으로 가져가지만 서브넷을 2~3개로 조율해서 2배수로 할지 3배수로 할지 미리 결정해두는 것이 좋다. 
- AWS의 AZ가 많은 virginia에 모든 AZ에 각 subnet을 쓸 경우 요금 폭탄 각 (terraform을 쓴다면 적당히 `slice` or `range` 사용)

```
│   InvalidParameter: "targetNumberOfBrokerNodes",
│   Message_: "The number of broker nodes must be a multiple of Availability Zones in the Client Subnets parameter."
```

# 그 외 카프카 국룰 

## 당연히 Broker node 수량보다 replication_factor가 높을 수 없다.
그럼에도 불구하고 aws msk 생성되는데는 지장 없다.

## kakfa는 다른 것보다 retention.hour가 종요하다.
잘못 두면 디스크 풀차는 것을 볼 수 있으니 미리 잘 산정할 필요가 있다.




