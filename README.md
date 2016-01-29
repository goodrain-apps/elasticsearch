# dockerfile for elasticsearch:2.1


> Elasticsearch是一个实时分布式搜索和分析引擎。它让你以前所未有的速度处理大数据成为可能。
>
> 更多信息参见： [Elasticsearch 是什么](http://es.xiaoleilu.com/010_Intro/05_What_is_it.html)

<a href="http://app.goodrain.com/app/19/" target="_blank" ><img src="http://www.goodrain.com/images/deploy/button_16012601.png" width="147" height="32"></img></a>


# 目录
- [部署到好雨云](#部署到好雨云)
	- [ELK结构](#ELK结构)
	- [一键部署](#一键部署)
- [部署到本地](#部署到本地)
	- [拉取或构建镜像](#拉取或构建镜像)
		- [拉取镜像](#拉取镜像)
		- [构建镜像](#构建镜像)
	- [运行](#运行)
- [支持的Docker版本](#支持的Docker版本)
- [用户反馈](#用户反馈)
	- [相关文档](#相关文档)
	- [问题讨论](#问题讨论)
	- [参与项目](#参与项目)
- [版权说明](#版权说明)

# 部署到好雨云
## ELK结构
![elk](https://github.com/goodrain-apps/logstash/blob/master/2.1/img/elk_dockerfile.png)

## 一键部署
通过点击本文最上方的 “安装到好雨云” 按钮会跳转到 好雨应用市场的应用首页中，可以通过一键部署按钮安装

**注意：**

- Kibana 应用依赖 Elasticsearch 和 Logstash 应用，因此在安装 Kibana 时会自动安装其它两个依赖的应用
- 需要日志处理的应用请在 依赖服务 中关联 logstash 应用，应用与logstash可以是一对一的关系，也可以是多对一的关系，还可以是多对多的关系。
- Elasticsearch 目前是单个实例，集群模式后续更新


# 部署到本地
## 拉取货构建镜像
### 拉取镜像
```bash
docker pull goodrain.io/elasticsearch:2.1_latest

# rename tag
docker tag -f goodrain.io/elasticsearch:2.1_latest kibana
```
### 构建镜像
```bash
git clone https://github.com/goodrain-apps/elasticsearch.git
cd elasticsearch
docker build -t elasticsearch  .
```
## 运行
可以运行默认的 `elasticsearch` 命令:
```bash
$ docker run -d elasticsearch
```


也可以为 `elasticsearch` 命令指定一个参数:

```bash
$ docker run -d elasticsearch elasticsearch -Des.node.name="TestNode"
```

这个镜像会有一个默认的配置文件，如果你想使用自己的配置文件，可以通过挂载到 `/usr/share/elasticsearch/config` 目录来实现：

```bash
$ docker run -d -v "$PWD/config":/usr/share/elasticsearch/config elasticsearch
```

这个镜像将 `/usr/share/elasticsearch/data` 作为持久化索引数据的目录，你可以将宿主机的一个目录挂载到容器内实现索引数据持久化的目的：

```bash
$ docker run -d -v "$PWD/esdata":/usr/share/elasticsearch/data elasticsearch
```

这个镜像会暴露9200和 9300端口( EXPOSE 9200 9300 ) ([default `http.port`](http://www.elastic.co/guide/en/elasticsearch/reference/1.5/modules-http.html))，因此使用容器连接的形式将会自动识别。

# 支持的Docker版本
该镜像支持  Docker 1.9.1 版本，最低支持到 1.6

请参考 [ Docker 安装文档](https://docs.docker.com/installation/) 来升级你的Docker

# 用户反馈
## 相关文档

- [Elasticsearch 2.1 镜像说明文档](https://github.com/goodrain-apps/elasticsearch/blob/master/README.md)
- [Elasticsearch 中文文档](https://www.gitbook.com/book/looly/elasticsearch-the-definitive-guide-cn)


## 问题讨论
- [GitHub issue](https://github.com/goodrain-apps/elasticsearch/issues)
- [kibana 好雨云社区讨论]()

## 参与项目
如果你觉得这个镜像很有用或者愿意共同改进项目，可以通过如下形式参与：

- 如果有新特性或者bug修复，请发送 一个 Pull 请求，我们会及时反馈。

# 版权说明

- 官方 [ 版权信息 ](https://github.com/elasticsearch/elasticsearch/blob/66b5ed86f7adede8102cd4d979b9f4924e5bd837/LICENSE.txt) 同样适用于本镜像
