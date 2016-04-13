FROM goodrain.me/jre:8u77
MAINTAINER zhouyq@goodrain.com

ENV ES_VERSION      2.3.1
ENV NODENET_VERSION 0.1

# Install Elasticsearch.
RUN apk add  --no-cache curl && \
  curl -Lskj https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/$ES_VERSION/elasticsearch-$ES_VERSION.tar.gz | \
  tar -xzC / && \
  mv /elasticsearch-$ES_VERSION /elasticsearch && \
  chown rain.rain /elasticsearch -R && \
  rm -rf $(find /elasticsearch | egrep "(\.(exe|bat)$|sigar/.*(dll|winnt|x86-linux|solaris|ia64|freebsd|macosx))")

# install NodeNetPlugin cluster discovery program
RUN wget -O /usr/local/bin/NodeNetPlugin "https://github.com/goodrain/NodeNetPlugin/releases/download/${NODENET_VERSION}/NodeNetPlugin" && \
    chmod +x /usr/local/bin/NodeNetPlugin

ENV PATH /elasticsearch/bin:$PATH

# Volume for Elasticsearch data
VOLUME /data

# 修改java运行参数
COPY bin/*.sh /elasticsearch/bin/

# Copy configuration
COPY config/* /tmp/

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 9200 9300

CMD ["elasticsearch -d"]
