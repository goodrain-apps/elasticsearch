#!/bin/bash

NODE_LIST=$(echo $1 | sed  's/,/","/g')

CLUSTER_LIST="[\"${NODE_LIST}\"]"

sed -i -r "s/#(discovery.zen.ping.unicast.hosts:) .*/\1 $CLUSTER_LIST/" /elasticsearch/config/elasticsearch.yml && \
echo "Elasticsearch config updated successfully."
