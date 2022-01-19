---
layout: post
title:  "AWS_TRANSER_SERVER Cannot specify more than 3 SubnetIds"
categories: ["sftp", "error"]
---

```
aws_eip.sftp_eip[0]: Creating...
aws_eip.sftp_eip[3]: Creating...
aws_eip.sftp_eip[1]: Creating...
aws_eip.sftp_eip[2]: Creating...
aws_s3_bucket.s3_bucket: Creating...
aws_security_group.sg_sftp: Creating...
aws_eip.sftp_eip[0]: Creation complete after 1s [id=eipalloc-016864015b39242b4]
aws_eip.sftp_eip[3]: Creation complete after 1s [id=eipalloc-0de8db64fac839459]
aws_eip.sftp_eip[1]: Creation complete after 1s [id=eipalloc-043b292e36a933d74]
aws_eip.sftp_eip[2]: Creation complete after 1s [id=eipalloc-00b1b255c52520187]
aws_s3_bucket.s3_bucket: Creation complete after 1s [id=dec9th-sftp]
aws_security_group.sg_sftp: Creation complete after 2s [id=sg-0343bd90f6f0a6496]
aws_transfer_server.sftp_server: Creating...
╷
│ Error: error creating Transfer Server: InvalidRequestException: Cannot specify more than 3 SubnetIds
│ 
│   with aws_transfer_server.sftp_server,
│   on main.tf line 40, in resource "aws_transfer_server" "sftp_server":
│   40: resource "aws_transfer_server" "sftp_server" {
```

조건 사항
 - terraform 내 설정은 vpc는 `default vpc` 지정
 - subnet은 전체 subnet 적용(한국기준 4개)
 - subnet은 az 당 1개씩 생성되어 있는 상태
 - 할당 가능한 az는 a, b, c, d

결론 
- `plan`에서 걸러지지 않는다. 
- 3개정도로 끊어서 사용
