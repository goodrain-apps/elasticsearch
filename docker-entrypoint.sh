#!/bin/bash

set -x

CONFDIR="/data/config"
ESLOGCONFIG="logging.yml"
ESCONFIG="elasticsearch.yml"
HOST_IP=`ip a | grep eth1 | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'`
export HOST_IP

# set environment
export CLUSTER_NAME=${CLUSTER_NAME:-elasticsearch-default}
export NODE_MASTER=${NODE_MASTER:-true}
export NODE_DATA=${NODE_DATA:-true}
export HTTP_ENABLE=${HTTP_ENABLE:-true}
export MULTICAST=${MULTICAST:-true}

# 初始化创建目录
for path in /data/data /data/logs /data/config /data/config/scripts
do 
    [ ! -d $path/$POD_ORDER ] && mkdir -pv $path/$POD_ORDER
    chown -R rain:rain $path
done


# 创建持久化目录
if [[ $SERVICE_EXTEND_METHOD = "state-expend" ]];then
    if [[ $POD_ORDER != "" ]];then
        action=${POD_ORDER:0:1}
        pod_order=${POD_ORDER:1}
        
        if [[ $action = "b" ]];then
            rm -rf /data/$pod_order
	fi
	
	mkdir -pv /data/$pod_order
	chown rain.rain /data/ -R
    fi
fi

# install discovery-multicast plugin
cp /tmp/tmp_elasticsearch.yml /elasticsearch/config
/elasticsearch/bin/plugin install discovery-multicast

# 处理 elasticsearch 配置文件
cp /tmp/${ESCONFIG}  ${CONFDIR}/${POD_ORDER}/${ESCONFIG}
cp /tmp/${ESLOGCONFIG} ${CONFDIR}/${POD_ORDER}/${ESLOGCONFIG}

# 软连接 config 目录到 ES_HOME
if [ -d /elasticsearch/config ];then
  rm -rf /elasticsearch/config
  ln -s /data/config/${POD_ORDER} /elasticsearch/config
fi

# Add elasticsearch as command if needed
if [ "${1:0:1}" = '-' ]; then
	set -- elasticsearch "$@"
fi

# Drop root privileges if we are running elasticsearch
if [ "$1" = 'elasticsearch' ]; then
	# Change the ownership of /usr/share/elasticsearch/data to elasticsearch
	chown -R rain.rain /data/data
	exec gosu rain "$@"
fi

# As argument is not related to elasticsearch,
# then assume that user wants to run his own process,
# for example a `bash` shell to explore this image
exec "$@"
