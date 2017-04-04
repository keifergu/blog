---
title: 异步 JavaScript 之事件与闭包
categories:
  - 异步 JavaScript
tags:
  - JavaScript
  - 前端
date: 2017-04-01 22:35:17
---
本文将讲解在 JavaScript 中的事件到底是怎么运行的，以及闭包在其中所起到的重要的作用。阅读完本文后，相信你会对一些常见的事件模型，例如 Node.js 中的 `Event`， Vue 或者 React 中的事件，都会有更深的体会。
<!-- more -->
## 前言
本文将讲解在 JavaScript 中的事件到底是怎么运行的，以及闭包在其中所起到的重要的作用。阅读完本文后，相信你会对一些常见的事件模型，例如 Node.js 中的 `Event`， Vue 或者 React 中的事件，都会有更深的体会。
## 事件
### 什么是事件
我们经常在各种文章中听到“事件”这个词语，不管是“事件循环机制”，还是浏览器的`onClick`等事件，我们在使用时都只需要去触发这个事件了，事先绑定的函数就将被调用，那么这里的事件到底是怎么运行的?

我们可以想想，首先我们需要在某个事件上绑定一个回调函数，当事件发生时这个函数会被调用：
```javascript
document.body.onload = function(){
    // do something
}
```
这样我们在浏览器 `body`的`onload`事件上**绑定**了一个回调函数，当浏览器页面加载完成后，浏览器**触发**这个事件时，我们绑定的函数将会被**调用**。这里想想，事件里面绑定的回调函数，是不是跟我们在异步操作里绑定的回调函数差不多，都是事先编写一个函数，然后当某件事做完后，我们就调用这个函数。

那么，实际上，是不是**绑定**操作就相当于把这个函数储存起来，**触发**的就是调用事先储存的函数.
### 实现一个 Event 类
我们来模拟 Node.js 中的 Event 模块来实现一个 Event 类：
```javascript
// Event 的构造函数
function Event(){
    this.events = {}
}

// on 方法负责对某个事件绑定回调函数
Event.prototype.on = function (event, callback) {
    this.events[event] = callback
}

// emit 方法负责触发事件
Event.prototype.emit = function(event) {
    this.events[event]()
}
```
这样，我们就实现了一个非常简单的 Event 模块，使用一下试试：
```javascript
var my = new Event()

my.on('load', function(){
    console.log('event emit')
})

setTimeout(function(){
    my.emit('load')
}, 1000)
```
一秒之后程序触发`load`事件，实际上触发事件就是运行事先储存好的函数。是不是感觉很简单，这有什么啊。但是，这就是事件机制的最基础的，最核心的模型或者说形式。接下来，我们需要做的是，错误处理，触发事件时需要传入参数等。稍微多写点代码：
```javascript
function Event(){
    this.events = {}
}

Event.prototype.on = function (event, callback) {
    // 处理初次绑定事件的情况
    if (this.events[event] instanceof Array === false){
        this.events[event] = []
    }
    // 可以针对一个事件绑定多个回调函数
    this.events[event].push(callback)
}

Event.prototype.emit = function(event, argument) {
    var _this = this,
        _arguments = arguments,
        queue = []
    if (this.events[event] instanceof Array === true) {
        queue = this.events[event]
    } else {
        throw new ReferenceError("event " + event + " not exist")
    }
    while(queue.length) {
        // 绑定 this 到当前的 Event 实例上，并将触发事件时的参数传入进去
        queue.shift().apply(_this, Array.prototype.slice.call(_arguments, 1))
    }
}
```
这样，我们就实现了一个最基本的 Event 方法，包括基本的错误处理与事件绑定触发行为。

## 闭包在其中的作用
很多人听到闭包可能第一反应是这道经典的面试题：
```javascript
for(var i = 0; i < 6; i++) {
    setTimeout(function() {
        console.log(i); 
    }, 0)
}
```
然后改为：
```javascript
for(var i = 0; i < 6; i++) {
    (function(i) {
        setTimeout(function() {
            console.log(i); 
        }, 0)
    })(i)
}
```
这道题其实应该是考察的使用`var`声明的变量只有函数作用域，而没有块作用域，以及使用 [IIFE](https://segmentfault.com/a/1190000003985390) 和闭包机制来解决该问题。但是，请记住：
- **闭包是 JavaScript 中最根本的函数执行机制**
- **只要你传递函数，你就使用了闭包**

在我们刚刚的事件模型中，我们把事件发生时的回调函数放在 `Event` 实例中，但是最终调用这个函数时，不管它是在哪个作用域，它都能正确的访问到闭包创建时的作用域内的变量，我们来看下面代码：
```javascript
var a = 'print a',
  b = 'print b'
function run(param){
  eval('console.log('+param+')')
}


setTimeout(run,1000,'a') // 打印出字符串 'print a'
setTimeout(run,1000,'b') // 打印出字符串 'print b'
```

我们将 `run` 设置为在 1s 后运行，在这时候，我们的脚本已经执行完了，`run`任务被从 task queue 中取出来，我们用`eval`来动态的执行语句。结果是，我们仍然**具有对函数创建时作用域内变量的完全控制能力**，这也是为什么不论这个函数什么时候，在什么地方调用，该函数始终能够对它作用域内的变量进行访问，修改。

看到这里，我想大家应该已经明白**闭包**在 JavaScript 中的重要性，可以说与**原型链**同为该编程语言的核心范型也不为过。理解了这两个概念，一定程度上就理解了 JavaScript 这门语言。

