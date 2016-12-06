---
title: Tensorflow 学习笔记
date: 2016-11-22 19:29:23
tags: tensorflow
---
## 安装
注意： 中文文档中所安装的版本已经过期，请使用[官方安装指南](https://github.com/tensorflow/tensorflow/blob/master/tensorflow/g3doc/get_started/os_setup.md)安装！
文档地址(仅做内容参考，其中的下载地址均已过期或老旧)：[Tensorflow中文文档](http://www.tensorfly.cn/tfdoc/get_started/introduction.html)
首先安装`pip`:
```bash
sudo apt-get install python-pip python-dev
```
由于国内下载`pip`上的软件包缓慢，所以使用国内源手动安装一部分：
```bash
sudo pip install --upgrade numpy -i http://pypi.doubanio.com/simple --trusted-host pypi.doubanio.com
```
然后使用以下命令安装`tensorflow`：
```bash
sudo pip install --upgrade https://storage.googleapis.com/tensorflow/linux/cpu/tensorflow-0.11.0-cp27-none-linux_x86_64.whl
```

安装完毕后测试是否可以正常使用，打开一个`python`终端：
```python
$ python

>>> import tensorflow as tf
>>> hello = tf.constant('Hello, TensorFlow!')
>>> sess = tf.Session()
>>> print sess.run(hello)
Hello, TensorFlow!
>>> a = tf.constant(10)
>>> b = tf.constant(32)
>>> print sess.run(a+b)
42
>>>
```
至此，软件安装完毕，有任何问题可以查看[官方安装指南](https://github.com/tensorflow/tensorflow/blob/master/tensorflow/g3doc/get_started/os_setup.md),看是否有解决办法。

## MNIST训练
### 下载数据
`Tensorflow`的代码仓库已经从 GoogleSource 迁移到了 [Github](https://github.com/tensorflow/tensorflow/tree/master/tensorflow),所以指南上提供的链接已经下载不了了。 

我建议直接下载整个仓库，因为后面教程需要的所有代码也在里面，后面就不用再下了。

克隆 TensorFlow 仓库:
`git clone git@github.com:tensorflow/tensorflow.git`

下载完毕后进入`tensorflow/examples/tutorials/mnist/`目录，这里存放着`MNIST`的所有代码。

在当前目录创建`mymnist.py`文件，内容为：
```python
import input_data
mnist = input_data.read_data_sets("MNIST_data/", one_hot=True)
```

然后运行该文件，即会自动下载并解压数据。
### 模型训练
#### 准备工作
阅读这段文字时，我会假设你已经完整的看了一遍
[MNIST入门](http://www.tensorfly.cn/tfdoc/tutorials/mnist_beginners.html)
，并将文章中的代码运行了一遍。以下是完整的'mymnist.py'代码：
```python
import input_data
import tensorflow as tf

mnist = input_data.read_data_sets("MNIST_data/", one_hot=True)

x = tf.placeholder("float", [None, 784])
W = tf.Variable(tf.zeros([784, 10]))
b = tf.Variable(tf.zeros([10]))

y = tf.nn.softmax(tf.matmul(x, W) + b)

y_ = tf.placeholder("float", [None, 10])
cross_entropy = -tf.reduce_sum(y_ * tf.log(y))
train_step = tf.train.GradientDescentOptimizer(0.01).minimize(cross_entropy)

init = tf.initialize_all_variables()
sess = tf.Session()
sess.run(init)

for i in range(1000):
  batch_xs, batch_ys = mnist.train.next_batch(100)
  sess.run(train_step, feed_dict={x: batch_xs, y_: batch_ys})

correct_prediction = tf.equal(tf.argmax(y,1), tf.argmax(y_,1))
accuracy = tf.reduce_mean(tf.cast(correct_prediction, "float"))
print sess.run(accuracy, feed_dict={x: mnist.test.images, y_: mnist.test.labels})
```
运行后会得到一个`0.91`左右的输出。
#### 数据集
训练集里面的数据包括图片和标签，例如手写的图片`1`，和对应的标签`1`。训练集的图片是一个28x28的图片，这里我们将其转换为一维的向量数据。我默认认为数据是按照列的方式展开，即从上到下，从左到右展开。

训练集的标签是一个10维向量，用来表示数字[0-9]，例如数字 2 ，就是([0,0,1,0,0,0,0,0,0,0])。
#### Softmax回归
>为了得到一张给定图片属于某个特定数字类的证据（evidence），我们对图片像素值进行加权求和。如果这个像素具有很强的证据说明这张图片不属于该类，那么相应的权值为负数，相反如果这个像素拥有有利的证据支持这张图片属于这个类，那么权值是正数。

例如说`1`,中间有连续向下的像素则说明很可能不是`0`,不是`9`等。在实际的数据中则是：
![图像-矩阵](http://www.tensorfly.cn/tfdoc/images/MNIST-Matrix.png)
在图像二维矩阵中的第[8-10]行或者是其它任意行有连续的`1`，在我们展开后的训练集中则是有大量的连续的`1`。这个就是一个很强的证据说明这个图片是数字`1`。

## 问题
1. `input_data.py` 无法使用
当尝试运行`input_data.py`时提示错误信息：
```python
from tensorflow.contrib.learn.python.learn.datasets.mnist import read_data_sets ImportError: No module named contrib.learn.python.learn.datasets.mnist
```
原因是因为你安装的 Tensorflow 版本过于老旧，请下载最新版本。

使用 `pip show tensorflow` 可以查看当前版本。具体安装方法请查看[官方安装指南](https://github.com/tensorflow/tensorflow/blob/master/tensorflow/g3doc/get_started/os_setup.md)或着本文章的安装部分，以官方为准。请先卸载旧版本（`sudo pip uninstall tensorflow`）再安装新版本。
