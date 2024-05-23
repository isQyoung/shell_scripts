#!/bin/bash
# 密码过期提醒, 低于7天自动续期

USER=$1
CHANGE=`date +%s -d "$(passwd -S $USER | awk '{print $3}')"`
NOW=`date +%s -d "$(date +%m/%d/%Y)"`
DAYS=$(($(($NOW-CHANGE))/86400))
EXPIRES=$(passwd -S $USER | awk '{print $5}')
EXPIRES_DAYS=$(($EXPIRES-$DAYS))
echo $EXPIRES_DAYS > /tmp/expires_days

if [ $EXPIRES_DAYS -le 7 ]
then
    echo "账号: $USER 密码剩余$EXPIRES_DAYS天过期,将被自动续期."
    chage -d $(date +%m/%d/%Y) $USER
elif [ $EXPIRES_DAYS -le 15 ]
then
    echo "账号: $USER 密码剩余$EXPIRES_DAYS天过期,请及时更新密码."
else
    echo "账号: $USER 密码过期时间超过15天"
fi

