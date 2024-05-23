#!/bin/bash
# 如果没有传递参数，默认使用 lo 作为网络接口
NIC=${1:-lo}
echo -e " In ------ Out"
while true; do
    # 使用awk命令从/proc/net/dev文件中提取指定网络接口的接收字节数和发送字节数，并保存到变量OLD_IN和OLD_OUT中
    OLD_IN=$(awk  '$0~"'$NIC'"{print $2}' /proc/net/dev)
    OLD_OUT=$(awk '$0~"'$NIC'"{print $10}' /proc/net/dev)
    # 等待1秒钟
    sleep 1
    # 再次使用awk命令提取最新的接收字节数和发送字节数，并保存到变量NEW_IN和NEW_OUT中。
    NEW_IN=$(awk  '$0~"'$NIC'"{print $2}' /proc/net/dev)
    NEW_OUT=$(awk '$0~"'$NIC'"{print $10}' /proc/net/dev)
    # 计算接收速率和发送速率，单位为KB/s，并保存到变量IN和OUT中
    IN=$(printf "%.1f%s" "$((($NEW_IN-$OLD_IN)/1024))" "KB/s")
    OUT=$(printf "%.1f%s" "$((($NEW_OUT-$OLD_OUT)/1024))" "KB/s")
    # 使用echo命令输出接收速率和发送速率
    echo "$IN $OUT"
    sleep 1
done
