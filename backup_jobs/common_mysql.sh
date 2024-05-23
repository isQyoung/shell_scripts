#!/bin/sh
  
if [ -z $1 ] || [ -z $2 ]; then
  echo "Usage: $0 mysql名称 mysqlip"
  exit 1
else
  ITEM="$1" # 备份环境的名称
  MYSQL_IP="$2" # 对应mysql的ip
fi

OUT_DIR=/opt/backup/${ITEM}/tmp #临时备份目录
TAR_DIR=/opt/backup/${ITEM}/list #备份存放路径
DATE=`date +%Y%m%d%H%M` #获取当前系统时间
DAYS=6 #DAYS=7代表删除7天前的备份，即只保留最近7天的备份
TAR_BAK="mysql_bak_$DATE.tar.gz" #最终保存的数据库备份文件名
MSG_LOG=/tmp/${ITEM}-messages

mkdir -p $OUT_DIR $TAR_DIR

#OLD_BAK=$(find $TAR_DIR/ -mtime +$DAYS)
#find $TAR_DIR/ -mtime +$DAYS -delete #删除7天前的备份文件
CMIN=9000
OLD_BAK=$(find $TAR_DIR/ -cmin +$CMIN)
find $TAR_DIR/ -cmin +$CMIN -delete #删除7天前的备份文件

cd $OUT_DIR #切换到临时备份目录
rm -rf $OUT_DIR/* #删除临时备份文件
mkdir -p $OUT_DIR/$DATE #创建临时备份目录

echo -e "\n$(date "+%Y/%m/%d %H:%M:%S") ${ITEM} 备份开始" > $MSG_LOG
passwd=$(cat ~/.mysql_key)
mysqldump --single-transaction -h ${MYSQL_IP} -P 3306 -u root --password=${passwd} --databases my_database > $OUT_DIR/$DATE/my_database.sql
if [ $? -eq 0 ];then
  echo "$(date "+%Y/%m/%d %H:%M:%S") ${ITEM}从$DATE 开始的备份已经完成." >> $MSG_LOG
  /opt/scripts/message.py ${ITEM}备份完成 $DATE
else
  echo  "$(date "+%Y/%m/%d %H:%M:%S") ${ITEM}从$DATE 开始的备份未完成,请检查相关服务器是否正常!!!" >> $MSG_LOG
  /opt/scripts/message.py ${ITEM}备份异常 $DATE
fi
#tar -zcvf $TAR_DIR/$TAR_BAK $OUT_DIR/$DATE #压缩为.tar.gz格式并存到备份路径
tar -cvPf - $DATE/*.sql | pigz -p 6 > $TAR_DIR/$TAR_BAK
if [ $? -eq 0 ];then
  echo "$(date "+%Y/%m/%d %H:%M:%S") ${ITEM}备份压缩已经完成." >> $MSG_LOG
else
  echo "$(date "+%Y/%m/%d %H:%M:%S") ${ITEM}备份压缩未正常完成,请检查相关服务器是否正常!!!" >> $MSG_LOG
fi
echo "$(date "+%Y/%m/%d %H:%M:%S") 删除7天前的备份 $OLD_BAK" >> $MSG_LOG
cat $MSG_LOG >> /var/log/backup/${ITEM}.log

echo -e "\n${ITEM}备份详情如下" >> $MSG_LOG
ls /opt/backup/${ITEM}/tmp/*/ -lh >> $MSG_LOG
echo -e "\n${ITEM}备份压缩包详情如下" >> $MSG_LOG
ls /opt/backup/${ITEM}/list/ -lh >> $MSG_LOG

MESSAGE=$(cat $MSG_LOG)
/opt/scripts/mail.py "${ITEM}备份提醒-${DATE}" "$MESSAGE"
