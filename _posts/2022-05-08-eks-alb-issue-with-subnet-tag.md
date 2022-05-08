---
layout: post
title:  "eks에서 alb 설치가 안되는 케이스 - unable to discover at least one subnet "
categories: ["eks"]
tags: ["eks"]
---


```
Failed build model due to couldn't auto-discover subnets: unable to discover at least one subnet
```

https://aws.amazon.com/ko/premiumsupport/knowledge-center/eks-load-balancer-controller-subnets/


위 경로와 같이 subnet을 사용할 수 있도록 tag를 넣어주어야 한다. 아래는 실제 tag 삽입을 위해 삽입한 코드 중 일부이다. 
```
  + resource "aws_ec2_tag" "public_subnet_tag" {
      + id          = (known after apply)
      + key         = "kubernetes.io/role/elb"
      + resource_id = "subnet-1234567890abcdef"
      + value       = "1"
    }
```
