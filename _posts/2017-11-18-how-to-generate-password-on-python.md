---
layout: post
title:  "How to generate a password on python"
categories: ["python", "ansible", "puppet", "passlib"]
featured-img: logo-python
---


# Overview

`linux` 내 패스워드 삽입 용도로 사용하기 좋은 *패스워드 생성 script* 입니다. 
실제 `ansible`, `puppet` 등에서 패스워드 삽입시 *plain text*가 아닌 *암호화된 패스워드*를 실제 삽입해야할 경우 유용합니다. 

# Password 생성을 위한 라이브러리 설치

Password를 생성해주는 `passlib` 라이브러리를 `pip`를 이용하여 설치합니다.

```shell
$ pip install passlib
```

# Password 생성 예제

```shell
$ python -c "from passlib.hash import sha512_crypt; import getpass; print sha512_crypt.encrypt(getpass.getpass())"
Password: 
```

위 명령 실행 후 password 부분에 암호를 넣으면 아래와 유사하게 출력됩니다.

```
$6$rounds=656000$fZ5yhukoUacz7TCB$efM4V.uZWsTayUzqle8reFni53qAB4t5cBR3axfTyMlcO/ZFmxOWTYKs7TyIiQfqkrlV4FJmh6WrGiqmK6MDb1
```

# Reference 

[passlib](https://passlib.readthedocs.io/en/stable/)
