#!/bin/sh
DUMP=/opt/mongodb/bin/mongodump #mongodump备份文件执行路径
OUT_DIR=/home/ubuntu/mongodb_bak/tmp #临时备份目录
TAR_DIR=/home/ubuntu/mongodb_bak/list #备份存放路径
DATE=`date +%Y%m%d%H%M` #获取当前系统时间
DAYS=6 #DAYS=7代表删除7天前的备份，即只保留最近7天的备份
TAR_BAK="mongodb_bak_$DATE.tar.gz" #最终保存的数据库备份文件名

Mail () {
echo -e "\n$MESSAGE" | mail -s "Mongodb备份提醒" \
 -S smtp="mail.xxx.com" \
 -S smtp-auth-user="alarm@xxx.com" \
 -S smtp-auth-password="123qwe!@#" \
 -S from="alarm@xxx.com" \
 -S smtp-auth=login \
 -a /tmp/mongodb.log \
  qyoung@xxx.com
}

cd $OUT_DIR #切换到临时备份目录
rm -rf $OUT_DIR/* #删除临时备份文件
mkdir -p $OUT_DIR/$DATE #创建临时备份目录
$DUMP --quiet -h 172.16.1.162:27200 -o $OUT_DIR/$DATE #备份全部数据库
if [ $? -eq 0 ];then
  echo "Mongodb从$DATE 开始的备份已经完成." > /tmp/mongodb-messages
else
  echo  "Mongodb从$DATE 开始的备份未完成,请检查相关服务器是否正常!!!" > /tmp/mongodb-messages
fi
tar -cvPf - $OUT_DIR/$DATE | pigz -p 4 > $TAR_DIR/$TAR_BAK   #压缩为.tar.gz格式并存到备份路径
#tar -zcvPf $TAR_DIR/$TAR_BAK $OUT_DIR/$DATE #压缩为.tar.gz格式并存到备份路径
#tar -zcvPf - $TAR_DIR/$TAR_BAK | openssl des3 -salt -k mongodbback -out $OUT_DIR/$DATE  #加密压缩为.tar.gz格式并存到备份路径
if [ $? -eq 0 ];then
  echo "Mongodb备份压缩已经完成." >> /tmp/mongodb-messages
else
  Mail "Mongodb备份压缩未正常完成,请检查相关服务器是否正常!!!" >> /tmp/mongodb-messages
fi
OLD_BAK=$(find $TAR_DIR/ -mtime +$DAYS)
echo "删除7天前的备份 $OLD_BAK" >> /tmp/mongodb-messages
find $TAR_DIR/ -mtime +$DAYS -delete #删除7天前的备份文件
#openssl des3 -d -k 你的密码 -salt -in 文件名.tar.gz | tar zxvf -     #使用密码解压压缩文件，去掉-k 参数可以通过stdin输入密码解压压缩文件
ls -lh /home/ubuntu/mongodb_bak/list/ > /tmp/mongodb.log
MESSAGE=$(cat /tmp/mongodb-messages)
Mail
