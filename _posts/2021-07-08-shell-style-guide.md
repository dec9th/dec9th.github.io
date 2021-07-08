---
title:  "Google Shell Style Guide"
layout: post
categories: shell
---


# Environment

## STDOUT vs STDERR

- 미리 상단에 `err()` 전용 함수 하나 박고 시작하자
- 모든 error는 `STDERR`로 전달

```
err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

if ! do_something; then
  err "Unable to do_something"
  exit 1
fi
```


# Formatting

## Indentation 
- Indent 2 spaces. No tabs.
- 블록단위로 blank를 달자 가독성을 위해
- 뭘하든 탭쓰지 말기
- 만약 존재하는 (남이 먼저쓴) 파일이 있다면 그 들여쓰기 문법에 충실(적응)하자


## Line Length and Long Strings

- 80자 초과하지 말자


## Pipelines
- 한줄로 가능하면 한줄로 쓰자
- 한줄로 불가하면 개행 후 두줄 들여쓰기와 함께 `|` 를 사용하여 가독성을 높인다. ( `||`, `&&` 도 동일)

```
# All fits on one line
command1 | command2

# Long commands
command1 \
  | command2 \
  | command3 \
  | command4
```


## Loops
- 한줄안에 `; do`, `; then`를 같이 넣어주자
- else는 통짜로 한줄 주자


## Case statement

- 들여쓰기 2칸
- `;;`으로 마무리짓는데 해당 공간은 통짜로 비우자
- 만약 명령어가 심플해서 1줄로 모두 가능할 경우  `;;` 역시 한줄로 

```
  case "${flag}" in
    a) aflag='true' ;;
    b) bflag='true' ;;
    f) files="${OPTARG}" ;;
    v) verbose='true' ;;
    *) error "Unexpected option ${flag}" ;;
  esac
```


# Naming Conventions

## Function Names

- 소문자와 `_` 를 사용한다.


## Variable Names

- 소문자와 `_` 를 사용한다.
- loop의 경우 아래와 같이 유사하게 변수명을 가져간다.  ($zones/$zone)

```
for zone in "${zones[@]}"; do
  something_with "${zone}"
done
```


## Constants and Environment Variable Names

- 모두 대문자로


## Source Filenames

- 소문자와 `_` 를 사용하고 `-`을 사용하지 않는다.


## Read-only Variables

- readonly가 필요할 경우 `readonly`, `declare -r`


## Use Local Variables

- local변수가 필요할 땐 `local`지정하여 사용


## Function Location

- 함수는 상수 아래 위치 시켜라
- 함수 내 실행 코드를 넣지마라 디버깅 간 지옥을 초래할 수 있다.


## Main

- 제일 아래 main함수를 넣어 실행하라. 
- 주석이 아닌 모든 명령의 제일아래에 두어라.


# Calling Commands

## Checking Return Values

- `exit 1`과 같이 return value를 넣어라.
- `PIPESTATUS[0]` 등을 통해 pipe결과를 확인하고 return_code를 만들어라.


## Builtin Commands vs. External Commands

- 빌트인을 사용하는 것을 우선시 하면 좋다. (명령어 자체가 또 하나의 프로세스가 되기 때문에 forking비용 있음)


---

# 마무리

종종 찾아보는 `google shell style guide` 
신규로 작성할 때 마다 다시 보고 작성함. ㅠㅠ 외워지지가 않네


# Reference

- https://google.github.io/styleguide/shellguide.html