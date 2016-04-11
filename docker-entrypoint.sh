#!/bin/bash

set -x

CONFDIR="/data/config"
ESLOGCONFIG="logging.yml"
ESCONFIG="elasticsearch.yml"

# 初始化创建目录
for path in /data/data /data/logs /data/config /data/config/scripts
do 
    [ ! -d $path/$POD_ORDER ] && mkdir -pv $path/$POD_ORDER
    chown -R elasticsearch:elasticsearch $path
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
	chown elasticsearch.elasticsearch /data/ -R
    fi
fi

# 软连接 config 目录到 ES_HOME
if [ ! -d /usr/share/elasticsearch/config ];then
  ln -s /data/config /usr/share/elasticsearch/
fi

# Add elasticsearch as command if needed
if [ "${1:0:1}" = '-' ]; then
	set -- elasticsearch "$@"
fi

# Drop root privileges if we are running elasticsearch
if [ "$1" = 'elasticsearch' ]; then
	# Change the ownership of /usr/share/elasticsearch/data to elasticsearch
	chown -R elasticsearch:elasticsearch /data/data
	exec gosu elasticsearch "$@"
fi

# As argument is not related to elasticsearch,
# then assume that user wants to run his own process,
# for example a `bash` shell to explore this image
exec "$@"
