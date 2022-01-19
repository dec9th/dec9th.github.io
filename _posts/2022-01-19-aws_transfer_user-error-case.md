---
layout: post
title:  "AWS_TRANSER_USER Cannot specify more than 3 SubnetIds"
categories: ["sftp", "error"]
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

사전 지식
 - `home_directory` : linux에서의 단순 홈 디렉토리와 동일  `ls`를 입력 할 경우 `/home/username`으로 출력될 수 있다.
 - `home_directory_mappings` : 지정한 값으로 임의의 경로를 만들어 줄 수 있다 예를 들면 **chroot** 잡아 주는 형태로 보안상 상위 폴더 등을 가리기 위해 `/home/username` 을 `/`로 변경 가능하다.

조건 사항
 - `home_directory_mappings`를 지정하여 배포 후에 `home_directory_mappings`를 삭제하고 `home_directory` 로 변경할 경우 위와 같은 에러가 발생한다.

해결 방법 
 
해결 방법 
