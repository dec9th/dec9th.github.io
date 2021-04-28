---
layout: post
title:  "Jmeter 설치"
categories: ["jmeter,java"]
featured-img: logo-redis
---

*Tested all on Windows Server 2019 DataCenter in AWS*

# Overview

Jmeter를 한번 설치해보고자 합니다. 특히 HTTP 프로토콜을 사용하는 Web에서는 굉장히 손쉽게 부하를 넣어볼 수 있는 Java로 만들어진 유용한 툴입니다.
GUI를 제공하며 5분 내 바로 우리의 서버가 실제 어느정도 부하를 버티는 지 볼 수 있습니다.  다수의 시나리오(로직)을 반영하여 테스트한다면 시나리오 양에 따라 세팅에 시간을 할애하겠지만 단순히 1~2 Requests 정도라면 5분 내 사용 가능 합니다.  필자는 여전히 게임업계 종사하고 있는데요. 초당 몇만의 RPS(or TPS)에 따른 수십만의 동접을 본 툴을 통해 종종 부하테스트를 하곤 합니다.

 *이글을 쓰는 시점이 2019년이라 이전과 크게 다른 점은 Oracle에서 Java에 대해 license 비용을 받기로하여 Oracle에서 다운받지 못한다는 점!*

 위 내용이 본 글을 쓰는 주된 이유 중 하나이기도 합니다.


# 01. JAVA 설치

*설치과정은 `Windows Server 2019 STD`에서 수행하였습니다.*

아래와 같이 Download Releases 페이지로 갑니다.  
https://jmeter.apache.org/download_jmeter.cgi


“Apache JMeter 5.1.1 (Requires Java 8+)” 제목 하단의 Brinaries에서 Windows에서 손쉽게 사용할 수 있는 zip 버전으로 다운 받습니다.  
전 아래의 파일을 다운 받았습니다.  알아서 국내 repo로 연결 시켜줍니다.

http://apache.tt.co.kr//jmeter/binaries/apache-jmeter-5.1.1.zip

제목에 쓰여진 Requires Java 8+ 처럼 Java 8 버전 이상을 설치 합니다.
Oracle Java License 이슈가 있어 아래와 같이 openjdk 에서 제공하는 source code의 Community build로 설치를 수행합니다.  
https://github.com/ojdkbuild/ojdkbuild

아래 링크는 제가 다운로드 받은 파일입니다.  
https://github.com/ojdkbuild/ojdkbuild/releases/download/1.8.0.212-1/java-1.8.0-openjdk-1.8.0.212-1.b04.ojdkbuild.windows.x86_64.zip

그리고 설치는 Default로 쭉 `Next` to `Finish` 합니다.


## OpenJDK 설치 과정

- 아래와 같이 `Next`  
![openjdk1](/assets/posts/2019-05-30-jmeter-installation/01.png)

- 아래와 같이 *I accept* 부분 체크하고 `Next`  
![openjdk2](/assets/posts/2019-05-30-jmeter-installation/02.png)

- 아래와 같이 `Next`  
![openjdk3](/assets/posts/2019-05-30-jmeter-installation/03.png)

- 아래와 같이 `Install`  
![openjdk4](/assets/posts/2019-05-30-jmeter-installation/04.png)

- 아래 창을 구경하시다가......  
![openjdk5](/assets/posts/2019-05-30-jmeter-installation/05.png)

- `Finish`버튼과 함께 설치 마무리하시면 됩니다.  
![openjdk6](/assets/posts/2019-05-30-jmeter-installation/06.png)


## OpenJDK 확인

아래와 같이 java 설치 여부는 가볍게 `cmd`에서 Version 체크를 통해 확인 가능합니다. 
```
C:\Users\santa>java -version
openjdk version "12.0.1-ojdkbuild" 2019-04-16
OpenJDK Runtime Environment 19.3 (build 12.0.1-ojdkbuild+12)
OpenJDK 64-Bit Server VM 19.3 (build 12.0.1-ojdkbuild+12, mixed mode, sharing)

```


# 02. Jmeter 설치

Jmeter 설치는 어렵지 않습니다. 
그냥 받은 파일 압출 풀면 설치는 끝!

실행 방법은 압축해제한 디렉토리 내 bin 디렉토리로 들어가면 jmeter.bat 실행하면 끝!

아래와 같이 cmd 콘솔 창과 함께 컬러풀(?)한 GUI 화면이 출력됩니다. 

```
Don't use GUI mode for load testing !, only for Test creation and Test debugging.
For load testing, use CLI Mode (was NON GUI):
   jmeter -n -t [jmx file] -l [results file] -e -o [Path to web report folder]
& increase Java Heap to meet your test requirements:
   Modify current env variable HEAP="-Xms1g -Xmx1g -XX:MaxMetaspaceSize=256m" in the jmeter batch file
Check : https://jmeter.apache.org/usermanual/best-practices.html

```

> 혹 IDC 내에서 상대적으로 낮은 스펙인 Memory 4GB 이하의 장비를 여러대 사용하셔야 되는 분들의 경우라면 권고된 설정과 함께 오히려 Linux에서 수행하는 것을 추천 드립니다. 

부하테스트 시 GUI를 사용하지 말라고 합니다만 GUI가 편하고 장비빨 된다면 사용하셔도 됩니다.


우선 Stress Test를 하려면 Bot이라고 불리는 놈이 있어야될텐데요.  
Bot 단위 설정을 위해 아래와 같이 `Thread Group`을 선택 합니다.  
![jmeter01](/assets/posts/2019-05-30-jmeter-installation/j01.png)

아래 `Thread Group` 창을 보시면 `Thread Properties`에 각각 1 씩 설정되어 있는 부분이 있는데요
본 설정은 이 3개만 알면 거의 끝이 납니다. 
- **Number of threads**: 사실 상 동시에 쏠 수 있는 봇 수량
- **Ramp-Up Period**: 위 Thread 와 아래 설명될 Loop Count 만큼이 본 설정의 시간 만큼 잘 수행되도록 즉, 수행에 걸리는 시간 입니다.
- **Loop Count**: 본 Plan을 몇 번 수행하겠다는 뜻입니다.  

![jmeter02](/assets/posts/2019-05-30-jmeter-installation/j02.png)


예를 들어 아래와 같이 설정 시 300초 간 따박따박 초당 1번식 Request 를 보낼 수 있습니다. 
```
- Number Of Threads:300
- Ramp-Up Period : 300
- Loop Count : 1
```
보통 안정적으로 Traffic을 넣을 때 Loop Count와 Ramp-Up Period를 잘 맞춰서 넣습니다.  
현업에서는 안정적으로 이상 적으로 넣으려고 Thread 를 Ramp-Up Period의 배수로 보통 넣습니다. 한번 더 산수를 해보면 Number of Thread를 200 넣고 Ramp-Up을 100 넣으면 초당 2Calls 씩 따빡따박 넣을 수 있습니다.

본문 끝에 한번 테스트 해보겠습니다. 

실제 Logic이라고 표현되는 시나리오를 넣어주기 위해 http 부하를 발생 시킬 수 있는 `HTTP Request` 를 하나 추가해보겠습니다. 

![jmeter04](/assets/posts/2019-05-30-jmeter-installation/j04.png)

아래와 같이 `Server Name or IP`에 google.com과 같은 도메인이나 저 처럼 IP를 바로 입력하시면 됩니다.  
그리고 `Method` 부분은 필요에 맞게 넣으시고요 `Path`의 경우 호출하고자 하는 파일 혹은 API 명을 넣어주시면 됩니다. 

그외 Paramater들이 필요할 경우 Parameters 항목을 이용하여 입력하면 됩니다. 
전 우선 아래와 같이 기재하였습니다. 

- Name : SampleAPI
- Server Name or IP : 10.1.1.111
- Path : sample.php

![jmeter05](/assets/posts/2019-05-30-jmeter-installation/j05.png)

사실 이정도면 부하 쏘는 것만 완성! 아직 *Run* 하지 말고!!  
그러나 부하를 잘 보내고 있는 지 확인을 위해 몇몇 확인용 기능을 추가해봅니다.
일단 한놈부터 잘되어야 하니 한놈한놈 Request, Response를 확인을 위해 **View Result Tree**를 추가합니다. 
![jmeter06](/assets/posts/2019-05-30-jmeter-installation/j06.png)

전 사실  **View Result Tree**를 제외하고는 Server Log정보가 훨씬 정확하다고 믿는 편이라 서버에서 대부분 확인합니다만 그냥 옵션으로 그리고 추가 설명을 위해 좌측과 같이 아래 2개의 기능을 더 추가합니다.  
위치는 위와 같이 Thread Group > Add > Listener에 있습니다.  
- **Summary Report** 
- **Response Time Graph** 

그리고는 이제 **Run**(`CTRL+R`)하시면 됩니다. 아래와 같이 노란화살표 아래 재생버튼 누르면 됩니다.  
![jmeter07](/assets/posts/2019-05-30-jmeter-installation/j07.png)

우리 설정이 Thread와 Ramp-up이 60/60 이었으니 1분 후 확인 하시면 아래와 같은 화면들을 볼 수 있을 겁니다. 

**View Result Tree**  
![jmeter11](/assets/posts/2019-05-30-jmeter-installation/j11.png)

**Summary Report**  
![jmeter12](/assets/posts/2019-05-30-jmeter-installation/j12.png)

**Response Time Graph**  
전 첫번째 그림 처럼 `Interval`을 1초로 넣고 `Display Graph`를 눌러야 초단위로 RPS 들의 평균을 볼 수 있습니다.  (Default : 10000ms[10초])
![jmeter13](/assets/posts/2019-05-30-jmeter-installation/j13-1.png)  
![jmeter14](/assets/posts/2019-05-30-jmeter-installation/j13-2.png)


여기까지가 Jmeter 설명이고 이쯤되면...  
그럼 RPS(or TPS)를 그래프로 보고 싶다고 하실 것 같은데요. **Graph Results**에서 확인 가능합니다만 현 버전에서 Y열 수치가 깔끔하게 나오지 않아 그냥 다른 툴 쓰는 것도 좋을 것 같습니다.  본문 중 언급한 바와 같이 TPS는 서버 측 수치로 보고 server 측 로그를 가지고 직접 확인 하는 것이 더 나이스 합니다. 실제 좋은 FOSS로는 Elastic Stack인 ELK 혹은 Influx DB + Grafana 조합도 나이스 합니다.  

마무리로 Jmeter는 Web 부하테스트 간 굉장히 유용하고 쓰입니다. 
경험 상 Google Market 인기 및 매출 순위의 top 10의 App을 서비스에도 본 툴을 통해 미리 검증하고 있습니다.  실제 좋은 기능으로 대기시간의 timer 라던지, 약간의 로직도 넣을 수 있고 가중치를 비롯 Random하게 Traffic을 부어볼 수 있습니다.

*불특정 다수를 겨냥한 대 유저 서비스라면 과부하로 인해 고객의 마음과 서버가 터지지 않도록 반드시 테스트 해보시길 추천 드립니다.* 

# Reference

[Official] https://jmeter.apache.org/  
http://jdk.java.net/12/  
https://github.com/ojdkbuild/ojdkbuild  
