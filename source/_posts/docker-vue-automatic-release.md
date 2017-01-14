---
title: 20分钟体验使用Docker自动构建、部署Web应用
date: 2017-01-13 19:49:08
tags: docker
---
# 前言
本文旨在带领读者们花费20分钟左右的时间，体验使用 Docker 以及 PaaS 服务自动化构建、发布 Web 应用，让大家了解到 Docker 这个工具的好处和便利。

首先我会假定读者拥有一个 [Github帐号](https://github.com) ，能进行基本的 git 操作。没有也没关系，两分钟就可以注册一个，而且我们这次只会使用最简单的几条 git 命令。

我使用的是 [vue-cli](https://github.com/vuejs/vue-cli) 创建的初始项目来作为样例，所以如果你的项目也是使用 vue-cli 创建的，那么只要将我提供的代码仓库中的 `Dockerfile`、`Dockerfile.sec`、`daocloud.yml` 三个文件拷贝到你的仓库中，然后经过下面的几步配置就可以使用了。

读完本文后你会了解到使用 Docker 进行前端应用的持续集成、自动化构建以及部署的工作流程。

# 准备工作
- 本次我们使用 [Daocloud](https://www.daocloud.io/) 作为Docker服务提供商，建议使用 Github 帐号注册，因为我们后面要使用 Github 作为代码源
- Fork 我为本文准备的样例仓库 [docker-vue-sample](https://github.com/keifergu/docker-vue-sample) 到你自己的 Github 仓库中

# 创建项目
首先我们需要使用代码构建出一个 Docker 镜像，作为最终的交付件。
- 登录并进入 [DaoCloud控制面板](https://dashboard.daocloud.io/)，选择 **项目** - **创建新项目**
- 项目名称随意，我这里填的是 "docker"
- 选择代码源，这里请选择 **`docker-vue-sample`** （请确定你已经**完成了准备工作**，并且绑定了 Github 帐号，并将我提供的代码仓库 Fork 到了你自己的帐号中。如果仓库没有显示，点击“设置代码源”右边的**刷新**按钮）
![creat](/images/create.png)
- 其余选项均为无关项，默认值即可
- 创建成功后可以看到构建流程已经定义好了
![details](/images/details.png)
- 现在我们需要手动构建一次，在右上角选择 master 分支，然后手动构建
![build](/images/build.png)
- 等待大约5分钟，构建完成，可以开始部署

# 创建应用并部署
- 进入 **[DaoCloud应用管理](https://dashboard.daocloud.io/apps)** - **创建新应用**，选择刚刚构建成功的镜像
![createapp](/images/createapp.png)
- 所有选项默认值即可，然后 **立即部署**
![appconfig](/images/appconf.png)
- 此时镜像已经开始了部署，等待大约1分钟，镜像部署成功
![app](/images/release.png)
- 点击访问地址即可访问应用
![vue](/images/vue.png)

# 自动化流程
上面所提到的构建、部署流程均可以自动完成。当我们向 Github 仓库提交代码后，根据事先定义的规则触发自动构建、部署
- 进入 **控制台** - **项目**，选择我们刚刚创建的项目，设置构建触发规则，由于我们是为了体验流程，所以添加规则为**提交代码到任意分支**即触发构建流程 
- 点击**触发规则** - **添加规则**，默认设置（提交代码到分支）即可，点击确定
![rule](/images/rule.png)
- 进入 **流水线**，设置部署规则
![pipline](/images/pipline.png)
- **添加应用**，选择我们刚刚创建的应用，打开 **自动发布**，选择触发规则为 **提交代码到分支**
![piprule](/images/piprule.png)
- 现在我们的自动构建、发布流程就定义好了
![pip](/images/pip.png)

# 修改并提交代码
在我们的工作流程中，当我们新版本的代码提交到了代码仓库中，我们就需要其触发自动构建流程并且发布到线上环境。这也是我们定义触发流程规则的意思所在，正常情况下，当我们的应用完成了新的版本，打上tag，意味着这是我们需要发布的版本，然后提交到仓库，此时自动构建并部署。

- 克隆你自己帐号中的样例仓库
`git clone git@github.com:<你的github账户名>/docker-vue-sample.git`
- 修改其中的一部分代码，我在下面添加了 "Docker" 字样
![code](/images/changecode.png)
- 提交代码
```bash
git add ./
git commit -m "change"
git push
```
- 此时回到控制台，可以发现已经触发了自动构建的流程
![autobuild](/images/autobuild.png)
- 这次构建会使用以前的缓存，所以会快的多，大概1分钟后，构建完成，自动部署到应用
- 打开应用的访问地址，可以看到最新版本已经发布上去了
![changeapp](/images/changeapp.png)

# 结语
至此，我们已经配置好了一个使用 Docker 自动构建并部署应用的工作流程。当我们向代码仓库 push 代码时，DaoCloud 会自动的拉取代码并构建，然后发布应用。在实际的工作流程中，我们还需要添加测试相关的配置，应用会先部署到开发环境，当测试通过后再部署到生产环境。这样的工作流程无疑大大的降低了运维的压力，减少了重复的工作，让开发人员能够更专注与代码当中。

感觉有点兴趣了？查看更加详细的 Docker 文档：
- Docker - 从入门到实践： https://yeasy.gitbooks.io/docker_practice/content/introduction/what.html
- Docker 官方文档（英文）： https://docs.docker.com/
- DaoCloud 文档：http://guide.daocloud.io/