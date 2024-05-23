#!/bin/bash
  
Mail () {
echo -e "\n$MESSAGE" | mail -s "${DATE} $SUBJECT" \
 -S smtp="mail.xxx.com" \
 -S smtp-auth-user="alarm@xxx.com" \
 -S smtp-auth-password="123456789" \
 -S from="alarm@xxx.com" \
 -S smtp-auth=login \
 -a $INFO \
 user@xxx.com
}

DATE=`date +%Y%m%d%H%M`
# 邮件主题
SUBJECT=$1
# 邮件内容
MESSAGE=$2
# 附件
INFO=$3

Mail

