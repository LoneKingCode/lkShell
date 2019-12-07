#!/bin/bash
HOST="1.1.1.1"
DOCKER_CERT="/root/docker"
function installDocker()
{
	curl -fsSL https://get.docker.com -o get-docker.sh
	sh get-docker.sh
}
function makeCert()
{
	if [ ! -d "${DOCKER_CERT}" ]; then
			mkdir ${DOCKER_CERT}
	fi
	cd ${DOCKER_CERT}
	openssl genrsa -aes256 -out ca-key.pem 4096
	openssl req -new -x509 -days 365 -key ca-key.pem -sha256 -out ca.pem
	openssl genrsa -out server-key.pem 4096
	openssl req -subj "/CN=${HOST}" -sha256 -new -key server-key.pem -out server.csr
	echo subjectAltName = DNS:${HOST},IP:${HOST}:127.0.0.1 >> extfile.cnf
	echo extendedKeyUsage = serverAuth >> extfile.cnf
	openssl x509 -req -days 365 -sha256 -in server.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out server-cert.pem -extfile extfile.cnf
	openssl genrsa -out key.pem 4096
	openssl req -subj '/CN=client' -new -key key.pem -out client.csr
	echo extendedKeyUsage = clientAuth > extfile-client.cnf
	openssl x509 -req -days 365 -sha256 -in client.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out cert.pem -extfile extfile-client.cnf
}
function runPortainer()
{
	docker volume create portainer_data
	docker run -d -p 8000:8000 -p 9000:9000 -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer
	echo "安装完成，请浏览器访问ip:9000进入面板"
}

echo -n "please enter ip:"
read HOST
#生成证书文件
makeCert
#安装docker
installDocker
#运行portainer
runPortainer
