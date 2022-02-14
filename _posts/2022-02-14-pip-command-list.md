---
layout: post
title:  "자주 사용하는 pip 명령어 목록"
categories: ["pip", "python"]
---

> 종종 찾아보는 pip 명령어 옵션들 기록

설치 
```
pip install ansible
```

패키지 삭제 
```
pip uninstall ansible
```

설치된 목록
 - rpm -qa  같은 출력
```
pip list ansible
```

설치된 패키지 정보 확인
 - rpm -qi 같은 출력
```
pip show ansible
```

설치된 패키지 파일 목록 확인
 - rpm -ql 같은 출력
```
pip show -f ansible
```

설치된 목록들  requirements.txt로 추출
```
pip freeze > requirements.txt
```

위의 패키지 리스트 설치 
```
pip install -r requirements.txt
```
