---
title: 在同一主机上运行不同域名的Web容器应用（基于nginx-proxy）
date: 2017-01-17 18:57:33
categories:
    - Docker
tags:
    - Docker
    - 运维
---
# 描述
当我们在需要同一个主机上运行不同域名的网站时，他们都需要绑定到`80`端口。以前使用 Apache 或者 Nginx 做 HTTP 服务器时，可以直接在其配置文件里面添加虚拟主机的相关配置。

现在当我们将网站的应用容器化之后：
1. 只能有一个进程监听`80`端口
2. 每个容器应用应该自己配置自己的域名
3. 每个容器的主机端口可能每次重启都会不一样（当然可以固定端口）

我们可以自己在主机上启动一个 Nginx 进程，然后将容器的端口固定，将其配置写进文件。但是这样当我们的容器迁移到其它主机后我们必须重新配置一次。

较好的方法是开启一个运行 Nginx 的 Docker 容器，将配置写进该容器里。但是当需要更改域名时又有一些麻烦了。
# 解决方案
[nginx-proxy](https://github.com/jwilder/nginx-proxy) 是一个基于 [docker-gen](https://github.com/jwilder/docker-gen) 的镜像。它使用 docker-gen 来自动获得主机上的容器端口，然后自动生成 Nginx 配置文件，实现代理。

# 使用方法
1. 运行 nginx-proxy
`$ docker run -d -p 80:80 -v /var/run/docker.sock:/tmp/docker.sock:ro jwilder/nginx-proxy`
2. 运行你的容器应用，加上环境变量`VIRTUAL_HOST=subdomain.youdomain.com`，值就是你想要为该容器绑定的域名
`$ docker run -e VIRTUAL_HOST=subdomain.youdomain.com  ...`

然后 nginx-proxy 会自动的获得你的容器在主机端口，然后配置好代理。当你使用 `subdomain.youdomain.com` 访问你的主机时，就可以看到已经正确的访问到了你的容器应用。