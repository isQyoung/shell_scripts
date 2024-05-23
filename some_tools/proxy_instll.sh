#!/bin/bash
# 使用apt代理安装软件
sudo apt -o Acquire::http::Proxy="http://192.168.1.100:3128/" install $1
