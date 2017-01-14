---
title: Pip 使用国内镜像
date: 2016-11-24 08:58:04
tags:
    - Python
---
官方文档地址：[User Guide — pip 9.0.1 documentation](https://pip.pypa.io/en/stable/user_guide/#configuration)
#### 新建或编辑配置配置文件
- Unix和macOS
`$HOME/.pip/pip.conf`
- Windows
`%HOME%\pip\pip.ini`
#### 添加配置信息
```bash
[global]
trutsed-host=pypi.doubanio.com
index-url=http://pypi.doubanio.com/simple
```
这里我使用的是豆瓣的镜像地址
