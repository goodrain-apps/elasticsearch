#!/bin/bash

[ $DEBUG ] && set -x

CONFDIR="/data/config"
ESLOGCONFIG="logging.yml"
ESCONFIG="elasticsearch.yml"
HOST_IP=`ip a | grep eth1 | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'`
export HOST_IP

INTER_IP=`ip a | egrep 'eth0' | grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'`
MULIT_IP="[\"$HOST_IP\", \"$INTER_IP\"]"
export MULIT_IP

# set environment
export NODE_MASTER=${NODE_MASTER:-true}
export NODE_DATA=${NODE_DATA:-true}
export HTTP_ENABLE=${HTTP_ENABLE:-true}
export MULTICAST=${MULTICAST:-true}

# 初始化创建目录
for path in data logs config plugins config/scripts
do 
    [ ! -d /data/$path/$POD_ORDER ] && \
    mkdir -pv /data/$path/$POD_ORDER && \
    chown -R rain:rain /data/$path
done


# 创建持久化目录
if [[ $SERVICE_EXTEND_METHOD = "state-expend" ]];then
    if [[ $POD_ORDER != "" ]];then
        action=${POD_ORDER:0:1}
        pod_order=${POD_ORDER:1}
        
        if [[ $action = "b" ]];then
            for dir in data config logs plugins
            do
              rm -rf /data/${dir}/${pod_order}
            done
	fi
    fi
fi

# process plugins dir
[ -d /elasticsearch/plugins ] \
&& rm -rf /elasticsearch/plugins \
|| ln -s /data/plugins/${POD_ORDER} /elasticsearch/plugins

# install discovery-multicast plugin
installed=`plugin list | grep discovery-multicast`
[ ! "$installed" ] && cp /tmp/tmp_elasticsearch.yml /elasticsearch/config/ && \
plugin install  discovery-multicast > /dev/null 2>&1

# 处理 elasticsearch 配置文件
cp /tmp/${ESCONFIG}  ${CONFDIR}/${POD_ORDER}/${ESCONFIG}
cp /tmp/${ESLOGCONFIG} ${CONFDIR}/${POD_ORDER}/${ESLOGCONFIG}

# 软连接 config 目录到 ES_HOME
if [ -d /elasticsearch/config ];then
  rm -rf /elasticsearch/config
  ln -s /data/config/${POD_ORDER} /elasticsearch/config
fi

# 单播的集群发现模式
if [ "$MULTICAST" != "true" ];then
    if [ "$NODE_DATA" == "true" ];then
       [ $DEPEND_SERVICE ] && SERVICE_NAME=${DEPEND_SERVICE%:*} || exit 1
    fi
	NodeNetPlugin -url=http://172.30.42.1:8080/api/v1/namespaces/${TENANT_ID}/endpoints/ \
       -regx_label=${SERVICE_NAME} \
       -frequency=once \
       -exec_num=3 \
       -interval=10 \
       -regx_port=9300 \
       -v=4 \
       -logtostderr=true \
       -rec_cmd=/elasticsearch/bin/config.sh
fi

sed -i -r "s/(network.host:) .*/\1 $MULIT_IP/" ${CONFDIR}/${POD_ORDER}/${ESCONFIG}
#sed -i -r "s/(transport.bind_host:) .*/\1 $HOST_IP/" ${CONFDIR}/${POD_ORDER}/${ESCONFIG}

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

exec "$@"
