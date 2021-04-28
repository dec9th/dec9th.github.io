---
layout: post
title:  "How to install node.js-v4 and pm2"
categories: node.js
tags: nodejs, logs
comments: true
---

# Overview

# repo 다운로드

```shell 
$ curl -sL https://rpm.nodesource.com/setup_4.x | bash -
```

# Install nodejs 

```shell 
$ yum install -y gcc-c++ make
$ yum -y install nodejs-4.4.5
```

# Install pm2

```shell 
$ npm install -g pm2
``` 

# service 명령을 위한 init 스크립트 생성 

아래와 같이 `startup` 옵션만으로 rcd 즉 service를 등록 할 수 있습니다. 

```shell 
$ pm2 startup
```

위와 같이 명령시 아래와 같은 출력이 발생합니다. 저 같은 경우 실제 시작 시 수행되는 `super()` 혹은 `start()` 함수를 수정하여 서비스 중에 있습니다.

```shell 
[PM2] Init System found: systemv
Platform systemv
Template
#!/bin/bash
### BEGIN INIT INFO
# Provides:        pm2
# Required-Start:  $local_fs $remote_fs $network
# Required-Stop:   $local_fs $remote_fs $network
# Default-Start:   2 3 4 5
# Default-Stop:    0 1 6
# Short-Description: PM2 Init script
# Description: PM2 process manager
### END INIT INFO

NAME=pm2
PM2=/usr/lib/node_modules/pm2/bin/pm2
USER=root
DEFAULT=/etc/default/$NAME

export PATH=/usr/bin:$PATH
export PM2_HOME="/root/.pm2"

# The following variables can be overwritten in $DEFAULT

# maximum number of open files
MAX_OPEN_FILES=

# overwrite settings from default file
if [ -f "$DEFAULT" ]; then
          . "$DEFAULT"
fi

# set maximum open files if set
if [ -n "$MAX_OPEN_FILES" ]; then
    ulimit -n $MAX_OPEN_FILES
fi

get_user_shell() {
    local shell=$(getent passwd ${1:-`whoami`} | cut -d: -f7 | sed -e 's/[[:space:]]*$//')

    if [[ $shell == *"/sbin/nologin" ]] || [[ $shell == "/bin/false" ]] || [[ -z "$shell" ]];
    then
      shell="/bin/bash"
    fi

    echo "$shell"
}

super() {
    local shell=$(get_user_shell $USER)
    su - $USER -s $shell -c "PATH=$PATH; PM2_HOME=$PM2_HOME $*"
}

start() {
    echo "Starting $NAME"
    super $PM2 resurrect
}

stop() {
    super $PM2 kill
}

restart() {
    echo "Restarting $NAME"
    stop
    start
}

reload() {
    echo "Reloading $NAME"
    super $PM2 reload all
}

status() {
    echo "Status for $NAME:"
    super $PM2 list
    RETVAL=$?
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    status)
        status
        ;;
    restart)
        restart
        ;;
    reload)
        reload
        ;;
    force-reload)
        reload
        ;;
    *)
        echo "Usage: {start|stop|status|restart|reload|force-reload}"
        exit 1
        ;;
esac
exit $RETVAL

Target path
/etc/init.d/pm2-root
Command list
[ 'chmod +x /etc/init.d/pm2-root',
  'mkdir -p /var/lock/subsys',
  'touch /var/lock/subsys/pm2-root',
  'chkconfig --add pm2-root',
  'chkconfig pm2-root on',
  'initctl list' ]
[PM2] Writing init configuration in /etc/init.d/pm2-root
[PM2] Making script booting at startup...
>>> Executing chmod +x /etc/init.d/pm2-root
[DONE] 
>>> Executing mkdir -p /var/lock/subsys
[DONE] 
>>> Executing touch /var/lock/subsys/pm2-root
[DONE] 
>>> Executing chkconfig --add pm2-root
[DONE] 
>>> Executing chkconfig pm2-root on
[DONE] 
>>> Executing initctl list
rc stop/waiting
tty (/dev/tty3) start/running, process 2557
tty (/dev/tty2) start/running, process 2554
tty (/dev/tty1) start/running, process 2551
tty (/dev/tty6) start/running, process 2563
tty (/dev/tty5) start/running, process 2561
tty (/dev/tty4) start/running, process 2559
update-motd stop/waiting
plymouth-shutdown stop/waiting
control-alt-delete stop/waiting
rcS-emergency stop/waiting
kexec-disable stop/waiting
quit-plymouth stop/waiting
rcS stop/waiting
prefdm stop/waiting
init-system-dbus stop/waiting
print-image-id stop/waiting
elastic-network-interfaces stop/waiting
splash-manager stop/waiting
start-ttys stop/waiting
now start/running, process 3056
rcS-sulogin stop/waiting
serial (ttyS0) start/running, process 2549
[DONE] 
+---------------------------------------+
[PM2] Freeze a process list on reboot via:
$ pm2 save

[PM2] Remove init script via:
$ pm2 unstartup systemv
```

# Generate logrodate configuration 

아래와 같이 `logrotate` 옵션만으로 로그 파일 관리를 위한 `logrotate`를 생성 할 수 있습니다. 

```shell
$ pm2 logrotate
[PM2] Getting logrorate template /usr/lib/node_modules/pm2/lib/templates/logrotate.d/pm2
[PM2] Logrotate configuration added to /etc/logrotate.d/pm2

# In my case as "root"
$ cat /etc/logrotate.d/pm2-root
/root/.pm2/pm2.log /root/.pm2/logs/*.log {
        rotate 12
        weekly
        missingok
        notifempty
        compress
        delaycompress
        copytruncate
        create 0640 root root
}
```

> 사용자 명 혹은 경로가 다르다면 먼저 `logrotate` 옵션을 통해 생성 후 수정하시면 됩니다.


# Reference

[node.js installation](https://nodejs.org/en/download/package-manager/)

[pm2](http://pm2.keymetrics.io/)
