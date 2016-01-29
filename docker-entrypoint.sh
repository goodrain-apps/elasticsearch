#!/bin/bash

set -e

CONFDIR="/data/config"
CONFURI="http://config.goodrain.me/apps/elasticsearch"
ESCONFIG="elasticsearch.yml"
ESLOGCONFIG="logging.yml"
RETRY=" -s --connect-timeout 3 --max-time 3  --retry 5 --retry-delay 0 --retry-max-time 10 "

# 获取配置文件 
if [ "$MEMORY_SIZE" == "" ];then
  echo "Must set MEMORY_SIZE environment variable! "
  exit 1
else
  echo "memory type:$MEMORY_SIZE"
  curl $RETRY ${CONFURI}/${MEMORY_SIZE}_${ESCONFIG} -o ${CONFDIR}/${ESCONFIG} && \
  curl $RETRY ${CONFURI}/${ESLOGCONFIG} -o ${CONFDIR}/${ESLOGCONFIG}
  if [ $? -ne 0 ];then
    echo "get ${MEMORY_SIZE} config error!"
    exit 1
  fi
fi


# 初始化创建目录
if [ ! -d /data/data ] && [ ! -d /data/logs ] && [ ! -d /data/config ];then
  for path in /data/data /data/logs /data/config /data/config/scripts
  do 
    mkdir -p "$path"
    chown -R elasticsearch:elasticsearch "$path"
  done
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
