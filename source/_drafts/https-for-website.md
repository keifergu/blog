---
title: 为网站启用https服务的流程步骤
date: 2016-10-25 16:12:07
tags: namecheap https ssl certificate website
---
以使用GitHub Education Pack提供的学生优惠为例，解释下如何为个人网站启用https服务。

首先使用学生优惠，在namecheap注册域名，购买一年的ssl服务。

#### 1. 生成CSR文件
首先你需要生成自己私钥文件和CSR文件，在服务器输入以下命令：

`openssl req -new -newkey rsa:2048 -nodes -keyout server.key -out server.csr`

你可以将其中的"server"替换为你自己的域名，然后你需要输入一些信息来生成`csr`文件和`key`文件。

```bash
Country Name (2 letter code) [AU]:CN
State or Province Name (full name) [Some-State]:Beijing
Locality Name (eg, city) []:Beijing
Organization Name (eg, company) [Internet Widgits Pty Ltd]:NA
Organizational Unit Name (eg, section) []:NA
Common Name (e.g. server FQDN or YOUR name) []:keifergu.me
Email Address []:keifergu@gmail.com

Please enter the following 'extra' attributes
to be sent with your certificate request
A challenge password []:
An optional company name []:
```
其中最重要的两个信息是`Common Name`和`Email Address`。
- `Common  Name`：需要输入域名，根据不同的公司提供的不同服务，这里可以签名的域名类型也不同，建议输入你需要启用ssl服务的域名。
- `Email Adress`：联系邮箱，最后的证书文件则会发送到该邮箱上。

完成之后可以在当前目录下面看到`server.csr`和`server.key`文件。

#### 2.配置ssl服务

找到你的服务商的ssl服务配置面板，neamcheap

#### 3.安装证书，使用https

#### 4.其他