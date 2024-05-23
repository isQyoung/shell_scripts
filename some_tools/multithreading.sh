#!/bin/bash
# 设置线程数为8
num=8
# 创建一个临时命名管道
pipefile="/tmp/ping_$$.tmp"
mkfifo $pipefile
# 把文件描述符12绑定命名管道
exec 12<>$pipefile
# 把跟线程数量一样的空字符串通过文件描述符存到命名管道内
for i in `seq $num`
do
    echo "" >&12 &
done
# 从文件描述符中读取内容并执行相应命令，线程数为8，满了8个后必须等待新字符传入文件描述符中才可以再次读取
for i in {1..254}
do
    read -u12
{
    ping 192.168.1.${i} -c 10
    echo "" >&12
}&
done
wait
# 用完删除临时命名管道
rm $pipefile
