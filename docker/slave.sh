#!/bin/bash
OS="centos"
DOCKER_SERVICE="/default"

function installDocker()
{
 	curl -fsSL https://get.docker.com | bash -s docker
}

function checkos(){
    if [ -f /etc/redhat-release ];then
        OS=centos
    elif [ ! -z "`cat /etc/issue | grep bian`" ];then
        OS=debian
    elif [ ! -z "`cat /etc/issue | grep Ubuntu`" ];then
        OS=ubuntu
    else
        echo "Not support OS, Please reinstall OS and retry!"
        exit 1
    fi
}

function configDockerService()
{
	checkos
	if [ "$OS" == 'centos' ]; then
		DOCKER_SERVICE=/usr/lib/systemd/system/docker.service
	else
		DOCKER_SERVICE=/lib/systemd/system/docker.service
	fi	
	echo DOCKER_SERVICE
	sed -i "s/ExecStart=.*/ExecStart=\/usr\/bin\/dockerd -H fd:\/\/ --containerd=\/run\/containerd\/containerd.sock -H tcp:\/\/0.0.0.0:2375 --tlsverify --tlscacert=\/root\/docker\/ca.pem --tlscert=\/root\/docker\/cert.pem --tlskey=\/root\/docker\/key.pem/g" ${DOCKER_SERVICE}
	echo "修改docker service文件配置完成，重启docker"
	systemctl daemon-reload
	if ! service docker restart; then
		 echo "重启docker失败"
		 exit 1
	fi
	service firewalld stop
	echo "重启docker完成，请去portainer中添加当前节点,记得设置TLS with client"
}

if [ ! -d "/root/docker" ]; then
			echo '请先将证书文件放到/roor/docker下'
			exit 1
fi
#安装docker
installDocker
#配置docker service
configDockerService