---
layout: post
title:  "datadog 관련 Terraform provider 관련 에러"
categories: ["datadog, terraform"]
---

실제 Provider 생성 간 아무것도 넣지 않았을 경우 아래와 같이 에러가 발생 할 수 있다. 
```
Error: Provider configuration not present

To work with module.alb_error_rate.datadog_monitor.default (orphan) its
original provider configuration at
provider["registry.terraform.io/datadog/datadog"] is required, but it has
been removed. This occurs when a provider configuration is removed while
objects created by that provider still exist in the state. Re-add the
provider configuration to destroy
module.alb_error_rate.datadog_monitor.default (orphan), after which you can
remove the provider configuration again.
```

2022년 초 최초 수행된 건으로 약 1년만에 업데이트를 진행하려다 보니 아래와 같이 에러가 발생했다. 
아래와 같이 Provider 를 넣어주고 수행하면 정상적으로 동작한다. 우리 내부 코드에도 없는 것 보니 실제 업데이트되면서 Deprecated 된 것으로 보인다.

```
terraform {
  ...

  required_providers {
    datadog = {
      source = "DataDog/datadog"
    }

  }
  ...
}
```
