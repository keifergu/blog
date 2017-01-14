---
title: 关于 Github Page 的 Vendors 文件夹无法访问的问题
date: 2016-11-07 21:18:41
tags: 
    - Github
---

主要原因是 Github Page 升级到了`Jekyll 3.3`，可以看[官方更新文章](https://github.com/blog/2277-what-s-new-in-github-pages-with-jekyll-3-3),而新版本的 Jekyll 会忽略`/vendor`和`/node_modules`文件夹，所以导致了我们的博客访问不正常。

![官方回复](/images/gitpage-vendor.png)

解决办法是在网站根目录下面新建一个空白`.nojekyll`文件。