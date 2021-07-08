---
layout: post
title:  "docker image cheat sheet"
categories: ["rundeck"]
---

# Install 
1. Download 
```
rpm -Uvh http://repo.rundeck.org/latest.rpm
```

2. install package
rundeck은 java 8 이상에서 구동 됩니다.  
```
yum -y install java-1.8.0-openjdk-devel  # install java8
yum -y install rundeck  
```

3. start a daemon
```
service rundeckd start
```

4. Server IP 설정

`grails.serverURL=http://localhost:4440` 로 기본 설정이 되어 localhost에서만 접속 가능하기에 외부 접속을 위해 공인IP로 변경해주어야 합니다.
AWS에서 실행하기에 `meta-data`를 통해 IP를 가져와서 입력 합니다.

```
#  Gettting public IP in AWS : curl 169.254.169.254/latest/meta-data/public-ipv4
$ sed -i "s/localhost/$(curl 169.254.169.254/latest/meta-data/public-ipv4)/g" /etc/rundeck/rundeck-config.properties
```

5. restart package
```
service rundeckd restart
```

6. visit URL
http://your-server-ip:4440


■ AWS EC2 Plug-In 설치 
1. 플러그인 다운로드 
sudo wget -N https://github.com/rundeck-plugins/rundeck-ec2-nodes-plugin/releases/download/v1.5.1/rundeck-ec2-nodes-plugin-1.5.1.jar -P /var/lib/rundeck/libext/

2. rundeck 재시작
service rundeckd restart 


■ 추가 정보 
New Project 를 들어가보면 키가 /var/lib/rundeck/.ssh/id_rsa에 있음을 알 수 있다. 
추가적으로 노드 정보는 var/rundeck/projects/${project.name}/etc/resources.xml 를 통해 핸들링할 수 있음을 알 수 있다. 
둘다 변경 가능하며 URL을 통한 노드 변경이 그럴싸하다. 

# AWS 작업 사항  
1. 계정 생성
- s3-rundeck 계정 생성

2. Permissions 적용
- AmazonEC2ReadOnlyAccess
- AmazonS3ReadOnlyAccess


■ 프로젝트 내 EC2 프로젝트 설정
1. "New Project" 선택하여 프로젝트 설정 페이지로 이동
2. "Project Name" 입력
3. "Description" 입력
4. Resource Model Source 내 "Add Source" 선택 
5. "AWS EC2 Resources" 선택
6. "Access Key", "Secret Key" 입력
- 위 '■ 추가 정보' 란에서 발급한 계정의 Key 정보 입력
7. "EndPoint" 란에 "ec2.ap-northeast-1.amazonaws.com" 입력
- Tokyo Region 일 경우 정상작동 하나 그 외 Region일 경우 정확한 endpoint를 찾아 기입하여야 한다. 
8. "Mapping Params" 에 "hostname.selector=privateIpAddress;nodename.selector=tags/Name,privateIpAddress;username.default=ec2-user;ssh-keypath.default=/path/to/key_20151015v1.pem" 와 같이 입력
- nodename.selector 값은 Node 명으로 보고자 하는 EC2 속성 입력
- username.default 값은 실제 서버에 접근할 username 입력하여야되며 정상동작을 위해 해당 계정 내 키 복사가 되어있어야 함. 
 - ssh-key 복사 명령어 : ssh-copy-id -i /var/lib/rundeck/.ssh/id_rsa.pub root@10.2.1.97
9. "save" in AWS EC2 Resource panel
10. "Create" in Configure Project page


■ 생성된 프로젝트 내 job 생성(ec2 위주 설명)
1. 작업하고자 하는 프로젝트 선택
2. 우측에 위치한 "Job Actions" 선택
3. "New job" 선택하여 Create New Job 페이지로 이동
4. "Job Name" 입력
5. "Desciption" 입력
6. Workflow 내 "Add a step" 선택
7. "Node Steps" 탭 내 "Command" 선택
8. Command 항목에  "hostname" 입력 후 "Save" 선택
9. Nodes 항목에 "Dispatch to Nodes" 선택
10. Node Filter 항목에 "ch-game.*" 입력 후 하단 좌측  "Save" 선택

* 마지막으로 만든 job을 실행하면 끝!





# tip

기본 설치 후 `ps` 결과를 보면 `-Xmx1024m`로 설정되어 있습니다. 1G 이하의 memory를 가진 서버에서는 512MB 이하로 설정해 줄 필요가 있습니다. 
```
$ ps -ef | grep java
root      3735     1  0 07:30 ?        00:00:00 runuser -s /bin/bash -l rundeck -c java -Drundeck.jaaslogin=true            -Djava.security.auth.login.config=/etc/rundeck/jaas-loginmodule.conf            -Dloginmodule.name=RDpropertyfilelogin            -Drdeck.config=/etc/rundeck            -Drundeck.server.configDir=/etc/rundeck            -Dserver.datastore.path=/var/lib/rundeck/data/rundeck            -Drundeck.server.serverDir=/var/lib/rundeck            -Drdeck.projects=/var/lib/rundeck/projects            -Dlog4j.configurationFile=/etc/rundeck/log4j2.properties            -Dlogging.config=file:/etc/rundeck/log4j2.properties            -Drdeck.runlogs=/var/lib/rundeck/logs            -Drundeck.server.logDir=/var/lib/rundeck/logs            -Drundeck.config.location=/etc/rundeck/rundeck-config.properties            -Djava.io.tmpdir=/tmp/rundeck            -Drundeck.server.workDir=/tmp/rundeck            -Dserver.http.port=4440            -Drdeck.base=/var/lib/rundeck  -Xmx1024m -Xms256m -XX:MaxMetaspaceSize=256m -server  -jar /var/lib/rundeck/bootstrap/rundeck-3.3.10-20210301.war --skipinstall
rundeck   3738  3735 87 07:30 ?        00:00:03 java -Drundeck.jaaslogin=true -Djava.security.auth.login.config=/etc/rundeck/jaas-loginmodule.conf -Dloginmodule.name=RDpropertyfilelogin -Drdeck.config=/etc/rundeck -Drundeck.server.configDir=/etc/rundeck -Dserver.datastore.path=/var/lib/rundeck/data/rundeck -Drundeck.server.serverDir=/var/lib/rundeck -Drdeck.projects=/var/lib/rundeck/projects -Dlog4j.configurationFile=/etc/rundeck/log4j2.properties -Dlogging.config=file:/etc/rundeck/log4j2.properties -Drdeck.runlogs=/var/lib/rundeck/logs -Drundeck.server.logDir=/var/lib/rundeck/logs -Drundeck.config.location=/etc/rundeck/rundeck-config.properties -Djava.io.tmpdir=/tmp/rundeck -Drundeck.server.workDir=/tmp/rundeck -Dserver.http.port=4440 -Drdeck.base=/var/lib/rundeck -Xmx1024m -Xms256m -XX:MaxMetaspaceSize=256m -server -jar /var/lib/rundeck/bootstrap/rundeck-3.3.10-20210301.war --skipinstall
```

`/etc/rundeck/profile` 파일 내 `RDECK_JVM_SETTINGS`을 수정하고 재시작하면 됩니다. 
```
RDECK_JVM_SETTINGS="${RDECK_JVM_SETTINGS:- -Xmx1024m -Xms256m -XX:MaxMetaspaceSize=256m -server}"

# to

RDECK_JVM_SETTINGS="${RDECK_JVM_SETTINGS:- -Xmx512m -Xms256m -XX:MaxMetaspaceSize=256m -server}"
```
솔직히 몇년간 수십개의 rundeck을 제공하며 운영해본 결과 1GB이상 필요한 케이스가 없습니다.  일주일 정도 모니터링하시고 최대한 memory 세이브해서 쓰셔도 됩니다.

# Reference
https://docs.rundeck.com/docs/administration/install/