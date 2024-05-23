#!/bin/bash

[ -d CA ] && echo '证书已存在' && exit 0
# 快速生成CA一套证书
# 以域名 *.abcd.com为例
DOMAIN="abcd.com"
# 私钥密码
PASS=123456

# 创建CA目录
mkdir -p CA
cd CA

# 创建 CA 私钥和公钥ca-key.crt
openssl genrsa -aes256 -passout pass:$PASS -out ca-key.crt 4096
# 用私钥创建 CA 证书ca.crt
openssl req -new -x509 -days 3650 -key ca-key.crt -sha256 -passin pass:$PASS -out ca.crt \
    -subj "/C=CN/ST=GD/L=SZ/O=${DOMAIN#*.}/OU=${DOMAIN%.*}/CN=${DOMAIN}"
# 创建服务器密钥server-key.crt
openssl genrsa -out server-key.crt 4096
# 创建服务器证书签名请求server.csr
openssl req -subj "/CN=*.${DOMAIN}" -sha256 -new -key server-key.crt -out server.csr
# 指定dns和ip
echo subjectAltName = DNS:localhost,DNS:*.${DOMAIN},IP:127.0.0.1 >> extfile.cnf
# 将 Docker 守护程序密钥的扩展使用属性设置为仅用于服务器身份验证
echo extendedKeyUsage = serverAuth >> extfile.cnf
# 生成服务器签名证书server-cert.crt
openssl x509 -req -days 3650 -sha256 -passin pass:$PASS -in server.csr -CA ca.crt -CAkey ca-key.crt \
    -CAcreateserial -out server-cert.crt -extfile extfile.cnf

# 创建客户端密钥client-key.crt
openssl genrsa -out client-key.crt 4096
# 创建客户端证书签名请求client.csr
openssl req -subj '/CN=client' -new -key client-key.crt -out client.csr
#将 Docker客户端密钥的扩展使用属性设置为仅用于客户端身份验证
echo extendedKeyUsage = clientAuth > extfile-client.cnf
# 生成客户端签名证书client-cert.crt
openssl x509 -req -days 3650 -sha256 -passin pass:$PASS -in client.csr -CA ca.crt -CAkey ca-key.crt \
    -CAcreateserial -out client-cert.crt -extfile extfile-client.cnf

chmod -v 0400 ca-key.crt server-key.crt client-key.crt
chmod -v 0444 ca.crt server-cert.crt client-cert.crt
rm -v client.csr server.csr extfile.cnf extfile-client.cnf
# 输出文件信息
echo "|####################生成文件如下######################|"
echo "| CA密钥:ca-key.crt         CA证书:ca.crt              |"
echo "| CA已签发的证书序列号的文件: ca.srl                   |"
echo "| 服务端密钥:server-key.crt 服务端证书:server-cert.crt |"
echo "| 客户端密钥:client-key.crt 客户端证书:client-cert.crt |"
echo "|######################################################|"
