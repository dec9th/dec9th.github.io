---
layout: post
title:  "Redis-stat"
categories: ["redis"]
featured-img: logo-redis
---

# Overview

`redis-stat` 은 `ruby` 로 작성된 `Redis` 모니터링 툴이며 **CLI** 환경에 최적화되어 있습니다. 물론 **Web Service** 역시 가능합니다.
본 가이드는 설치 및 단순 실행정도 다루며 `ElasticSearch` 연동 , `CSV` 적재 등 추가 기능이 있으나 사용 빈도수가 높지 않기에 본 페이지에서는 다루지 않습니다.

# Install Redis-stat

## 1. install requirement for Redis install 

```shell
$ yum -y install ruby-devel gcc gcc-c++
$ gem install redis-stat
```

`ruby-devel` 과 `Linux development tool` 중 `gcc` , `gcc-c++` 을 설치하지 않으면 `gem install` 간 error를 경험하게 됩니다.  반드시 설치하시고 `gem install` 로 넘어가세요.

# Run Redis-stat  

## 1. redis-stat 실행
 
저는 주로 실행 시 옵션으로 `IP` : `Port`  `주기(초)` 를 입력 해서 사용 합니다.

```bash
$ redis-stat 127.0.0.1:6379 1
```

위 명령 실행 시 아래와 같이 출력됩니다.

![run_redis-stat](/assets/posts/2017-11-02-redis-stat/run_redis-stat.png "run_redis-stat")

## 2. 추가 옵션 사항

실제 기본 실행이 본 기능의 99%이며 그 외 적재, 전송 등의 기능에 대해서는 아래와 같이 `help` 참조바랍니다.
결과에 대해 `CSV` 로 저장, `ElasticSearch` 로 전송도 가능합니다. 
`redmin` 처럼 web 에서 볼 수 있는 기능 역시 제공합니다. 

```shell
$ redis-stat --help

usage: redis-stat [HOST[:PORT] ...] [INTERVAL [COUNT]]
  -a, --auth=PASSWORD              Password
  -v, --verbose                    Show more info
      --style=STYLE                Output style: unicode|ascii
      --no-color                   Suppress ANSI color codes
      --csv[=CSV_FILE]             Print or save the result in CSV
      --es=ELASTICSEARCH_URL       Send results to ElasticSearch: [http://]HOST[:PORT][/INDEX]

      --server[=PORT]              Launch redis-stat web server (default port: 63790)
      --daemon                     Daemonize redis-stat. Must be used with --server option.

      --version                    Show version
      --help                       Show this message
```

# Trouble Shooting

## Case_1. `ruby-devel` 미 설치 시 ruby header file(ruby.h)이 없다고 출력될 경우

* Symptom

```shell
$ gem install redis-stat  # without ruby-devel

...
Fetching: eventmachine-1.2.3.gem (100%)
Building native extensions.  This could take a while...
ERROR:  Error installing redis-stat:
        ERROR: Failed to build gem native extension.
     /usr/bin/ruby2.0 extconf.rb
**mkmf.rb can't find header files for ruby at /usr/share/ruby/include/ruby.h**
...
```

* Possible solution

```shell
$ yum -y install ruby-devel 
```

## Case_2. `gcc` , `gcc-c++` 미 설치 시 complie 간 에러와 함께 *Development Tool* 관련 출력

* Symptom

```shell
$ gem install redis-stat  # without ruby-devel

...
Fetching: eventmachine-1.2.3.gem (100%)
Building native extensions.  This could take a while...
ERROR:  Error installing redis-stat:
        ERROR: Failed to build gem native extension.

    /usr/bin/ruby2.0 extconf.rb
checking for main() in -lcrypto... *** extconf.rb failed ***
Could not create Makefile due to some reason, probably lack of necessary
libraries and/or headers.  Check the mkmf.log file for more details.  You may
need configuration options.

Provided configuration options:
     --with-opt-dir
     --without-opt-dir
     --with-opt-include
     --without-opt-include=${opt-dir}/include
     --with-opt-lib
     --without-opt-lib=${opt-dir}/lib64
     --with-make-prog
     --without-make-prog
     --srcdir=.
     --curdir
     --ruby=/usr/bin/ruby2.0
     --with-ssl-dir
     --without-ssl-dir
     --with-ssl-include
     --without-ssl-include=${ssl-dir}/include
     --with-ssl-lib
     --without-ssl-lib=${ssl-dir}/
     --with-openssl-config
     --without-openssl-config
     --with-pkg-config
     --without-pkg-config
     --with-cryptolib
     --without-cryptolib
/usr/share/ruby/2.0/mkmf.rb:434:in `try_do': The compiler failed to generate an executable file. (RuntimeError)
You have to install development tools first.
     from /usr/share/ruby/2.0/mkmf.rb:519:in `try_link0'
     from /usr/share/ruby/2.0/mkmf.rb:534:in `try_link'
     from /usr/share/ruby/2.0/mkmf.rb:720:in `try_func'
     from /usr/share/ruby/2.0/mkmf.rb:950:in `block in have_library'
     from /usr/share/ruby/2.0/mkmf.rb:895:in `block in checking_for'
     from /usr/share/ruby/2.0/mkmf.rb:340:in `block (2 levels) in postpone'
     from /usr/share/ruby/2.0/mkmf.rb:310:in `open'
     from /usr/share/ruby/2.0/mkmf.rb:340:in `block in postpone'
     from /usr/share/ruby/2.0/mkmf.rb:310:in `open'
     from /usr/share/ruby/2.0/mkmf.rb:336:in `postpone'
     from /usr/share/ruby/2.0/mkmf.rb:894:in `checking_for'
     from /usr/share/ruby/2.0/mkmf.rb:945:in `have_library'
     from extconf.rb:8:in `block in check_libs'
     from extconf.rb:8:in `each'
     from extconf.rb:8:in `all?'
     from extconf.rb:8:in `check_libs'
     from extconf.rb:95:in `<main>'
...
```

* Possible solution

```shell
$ yum -y install gcc gcc-c++
```

> 두 Case 모두 *gem install redis-stat* 전 한번에 사전 설치로 마무리 지을 수 있습니다.

# Reference

[Official] https://github.com/junegunn/redis-stat


