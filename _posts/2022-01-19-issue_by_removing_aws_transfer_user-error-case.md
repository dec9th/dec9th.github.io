---
layout: post
title:  "aws_transfer_user의 home_directory_mappings 삭제 간 이슈"
categories: ["sftp", "error", "AWS_TRANSFER_USER"]
---

```
Terraform will perform the following actions:

  # aws_transfer_user.sftp_user will be updated in-place
  ~ resource "aws_transfer_user" "sftp_user" {
      ~ home_directory_type = "LOGICAL" -> "PATH"
        id                  = "s-29b24066bfaa4300a/santa"
        tags                = {}
        # (5 unchanged attributes hidden)

      - home_directory_mappings {
          - entry  = "/" -> null
          - target = "/dec9th-sftp" -> null
        }
    }

Plan: 0 to add, 1 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

aws_transfer_user.sftp_user: Modifying... [id=s-29b24066bfaa4300a/santa]
╷
│ Error: error updating Transfer User (s-29b24066bfaa4300a/santa): InvalidParameter: 1 validation error(s) found.
│ - minimum field size of 1, UpdateUserInput.HomeDirectoryMappings.
│ 
│ 
│   with aws_transfer_user.sftp_user,
│   on user.tf line 58, in resource "aws_transfer_user" "sftp_user":
│   58: resource "aws_transfer_user" "sftp_user" {
│ 
╵
```

## 사전 지식
- `home_directory` : linux에서의 단순 홈 디렉토리와 동일  `ls`를 입력 할 경우 `/home/username`으로 출력될 수 있다.
- `home_directory_mappings` : 지정한 값으로 임의의 경로를 만들어 줄 수 있다. 
  - 예를 들면 **chroot** 잡아 주는 형태로 보안상 상위 폴더 등을 가리기 위해 `/home/username` 을 `/`로 변경 가능하다.

## 조건 사항
- `home_directory_mappings`를 지정하여 배포 후에 `home_directory_mappings`를 삭제하고 `home_directory` 로 변경할 경우 위와 같은 에러가 발생한다.

## 해결 방법 

```
  home_directory_type ="PATH"
  home_directory      = "/dec9th-sftp"
  
  #home_directory_type ="LOGICAL"
  home_directory_mappings {
    entry  = "/"
    target = "/${aws_s3_bucket.s3_bucket.id}"
  }
```
- 위와 같이 `home_directory_mappings`를 살려두고 `home_directory_type = LOGICAL`만 제거하고 `terraform apply` 수행 이후 다시 `home_directory_mappings` 영역도 모두 제거 한 후 `terraform apply`한다. 
- 총 2번의 `terraform apply`가 필요하며 첫번째 `terraform apply` 시 `home_directory_type`이 `PATH`이기 때문에 `/dec9th-sftp`로 지정되며 접속 후 `ls` 명령시 `/dec9th-sftp`로 출력된다. 
- 또한 첫번째의 경우 tfstate확인 시 `LOGICAL`에서 `PATH`로 변경되었기에 아래와 같이 `home_directory_mappings` 역시 공란이다. 하지만 코드 상에 남아있기에 처음 보는 사람에게 혼란을 줄 수 있으니 지워주든 주석 쳐주는 두번째 `terraform apply` 해주는 센스가 필요하다.
```
# grep mapping terraform.tfstate.backup                                               
            "home_directory_mappings": [],
```
> 위의 케이스를 몰랐을 땐 지우고 새로 만들어야 되나 했음.... 이건 좀 패치가 필요하지 않나 싶다. 🥲
