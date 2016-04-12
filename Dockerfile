FROM goodrain.me/jre:8u77
MAINTAINER zhouyq@goodrain.com

ENV ES_VERSION 2.3.1

# Install Elasticsearch.
RUN apk add  --no-cache curl && \
  curl -Lskj https://download.elasticsearch.org/elasticsearch/release/org/elasticsearch/distribution/tar/elasticsearch/$ES_VERSION/elasticsearch-$ES_VERSION.tar.gz | \
  tar -xzC / && \
  mv /elasticsearch-$ES_VERSION /elasticsearch && \
  rm -rf $(find /elasticsearch | egrep "(\.(exe|bat)$|sigar/.*(dll|winnt|x86-linux|solaris|ia64|freebsd|macosx))")

ENV PATH /elasticsearch/bin:$PATH

RUN set -x \
	&& curl -o /usr/local/bin/gosu -fSL "https://github.com/tianon/gosu/releases/download/1.3/gosu-amd64" \
	&& chmod +x /usr/local/bin/gosu

# Volume for Elasticsearch data
VOLUME /data

# 修改java运行参数
COPY bin/elasticsearch.in.sh /elasticsearch/bin/

# Copy configuration
COPY config/* /tmp/

COPY docker-entrypoint.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 9200 9300

CMD ["elasticsearch"]
