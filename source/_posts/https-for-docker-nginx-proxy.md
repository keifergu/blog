---
title: 为 Docker 应用开启 HTTPS（基于nginx-proxy和Let's Encrypt）
date: 2017-02-22 22:35:17
categories:
    - Docker
tags:
    - Docker
    - 运维
---
## 前言
为了避免运营商的流量劫持，以及增强自己网站的安全性，启动 HTTPS 是一个非常不错的选择。

通过这篇文章，我们最后想要达到的效果是：

在启动 Docker 镜像时通过附带环境变量
```
VIRTUAL_HOST=example.com
LETSENCRYPT_HOST=example.com
LETSENCRYPT_EMAIL=foo@bar.com
```
让你的应用自动启用 HTTPS 连接，无需再做任何设置，无论多少个网站，均自动申请证书并配置 HTTPS。

## 开始
首先，你的应用需要是使用 Docker 部署的，然后你需要使用 nginx-proxy 镜像来为你的不同域名的应用自动设置端口转发。这是一个非常好用的工具，具体的介绍可以看我的前一篇文章（[在同一主机上运行不同域名的Web容器应用](/2017/01/17/different-domain-name-docker-application-run-in-one-host/))。

## 配置基本镜像应用
1. 首先你需要启动你的 nginx-proxy ，同时为它定义 3 个 volumes：
```bash
$ docker run -d -p 80:80 -p 443:443 \
    --name nginx-proxy \
    -v /path/to/certs:/etc/nginx/certs:ro \
    -v /etc/nginx/vhost.d \
    -v /usr/share/nginx/html \
    -v /var/run/docker.sock:/tmp/docker.sock:ro \
    jwilder/nginx-proxy
```
2. 然后启动[letsencrypt-nginx-proxy-companion](https://github.com/JrCs/docker-letsencrypt-nginx-proxy-companion) 容器。这个容器为你完成了申请证书，自动更新证书，绑定证书到不同域名等工作。
```bash
$ docker run -d \
    -v /path/to/certs:/etc/nginx/certs:rw \
    --volumes-from nginx-proxy \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    jrcs/letsencrypt-nginx-proxy-companion
```

## 启动你的应用
现在只需要重新启动你的网站容器，并添加它的域名，证书域名，以及你的邮件作为环境变量
```bash
$ docker run -d \
    --name example-app \
    -e "VIRTUAL_HOST=example.com,www.example.com,mail.example.com" \
    -e "LETSENCRYPT_HOST=example.com,www.example.com,mail.example.com" \
    -e "LETSENCRYPT_EMAIL=foo@bar.com" \
    tutum/apache-php
```

- `VIRTUAL_HOST` 为你这个容器应用的访问域名，可以有多个，以逗号隔开
- `LETSENCRYPT_HOST` 为你想启动 HTTPS 的域名，一般与 `VIRTUAL_HOST` 相同
- `LETSENCRYPT_EMAIL` 为你的 EMAIL 地址

等待一段时间，然后访问你的网站，就可以看到已经启用了 HTTPS：

![](images/https-for-blog.png)