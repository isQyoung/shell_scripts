#!/bin/bash
# 此脚本可以查询docker swarm中service的对应ip

if [[ -z $1 ]];then
  echo "缺少参数"
  echo "用法: $0 service的id 或者$0 service的名字"
  exit 1
fi
service_name=$(docker service ls|grep $1|awk '{print $2}')
echo "服务名: $service_name"
service_ip=$(docker service inspect $service_name --format '{{range .Endpoint.VirtualIPs}}{{.Addr}}{{end}}')
echo "服务ip: $service_ip"
service_task_id=$(docker service ps $service_name --filter desired-state=running -q)
service_task_count=$(docker service ps $service_name --filter desired-state=running -q|wc -l)
echo "服务对应$service_task_count个节点的主机如下"
docker service ps $service_name --filter desired-state=running | awk 'NR>2 {print $4}'
echo "服务对应$service_task_count个容器的ip如下:"
for i in $service_task_id;do
  service_container_ip=$(docker inspect $i --format '{{range .NetworksAttachments}}{{.Addresses}}{{end}}')
  echo $service_container_ip
done
