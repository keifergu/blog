FROM node:7.4.0
MAINTAINER Keifer Gu <keifergu@gmail.com>

RUN mkdir -p /app
WORKDIR /app

COPY package.json /app/
RUN npm config set registry https://registry.npm.taobao.org
	&& npm install
	&& npm install hexo-cli -g
COPY . /app
# 执行构建命令并将代码构建在 /app/dist 目录
RUN npm run next
	&& hexo generate
