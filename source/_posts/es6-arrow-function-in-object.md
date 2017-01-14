---
title: ES6箭头函数(arrow_function)的this值探究
date: 2016-12-06 16:10:37
categories:
    - 前端
tags: 
    - JavaScript
    - ECMAScript 6
---
## 前言
对于ES6新增的箭头函数,相关的介绍可以查看[MDN - Arrow_functions](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Functions/Arrow_functions)以及[ECMAScript 6 入门](http://es6.ruanyifeng.com/#docs/function#箭头函数)。

## 引入
首先我们先看下面一段代码：
```javascript
'use strict'
var obj = {
    i: 1,
    arrow: () => console.log(this.i),
    func: function(){ console.log(this.i); },
};

obj.arrow()  //undefined
obj.func()  // 1
```
这里为什么使用箭头函数定义的方法，不能访问到对象内的属性呢？

## Function定义的方法
这里我们先说为什么使用`function`定义的方法能够按照我们的预计正确读取到`i`的值。

首先，我们要明白，使用`function`定义的方法[MDN - Functions](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Functions)：
>在函数执行时，this 关键字并不会指向正在运行的函数本身，而是指向调用该函数的对象。

那么，也就是说，我们使用`function`定义的函数，在定义时，它并不知道这个`this`会指向哪里，只有在运行的时候才能明确`this`的值。

在这里，我们是使用`obj.func`，调用函数`func`的对象是`obj`，所以函数`func`的`this`被指向调用它的对象`obj`。所以此时`func`内的`this`是能够通过`this.i`访问到`obj.i`的。

那么如果我们像下面这样调用：
```javascript
'use strict'
var obj = {
    i: 1,
    arrow: () => console.log(this.i),
    func: function(){ console.log(this.i); },
};

var f = obj.func;

f(); // undefined 此时 this 指向 window
```
此时调用函数`func`的是`window`对象，所以函数`func`的`this`被指向了`window`，而`window`不具有`i`属性，显示`undefined`。

## 箭头函数定义的方法

接下来再来说说为什么使用箭头函数定义的方法不能访问到`obj`里的值。

首先，我们还是要明白[MDN - Arrow_functions](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Functions/Arrow_functions)：
>箭头函数拥有词法作用域的this值（即不会新产生自己作用域下的this, arguments, super 和 new.target 等对象）

箭头函数本身不具有`this`，它会直接绑定到它的词法作用域内的`this`，也就是定义它时的作用域内的`this`值。所以试图使用`apply`,`call`等方法修改箭头函数的`this`是不会成功的，因为箭头函数自身**没有`this`**。所以我们来看下面一段代码：
```javascript
var func = () => {
    console.log(this);
}

func(); // Window
func.apply({}); // Window
```
可以看出，箭头函数是直接使用的作用域内的`this`，`apply`等方法是无效的。为了加深理解，我们再来看下面一段代码：
```javascript
function func() {
    console.log(this)
    return () => {console.log(this)}
};

func()()
// Window 
// Window
func.apply({a:1})()
// Object {a:1}
// Object {a:1}
func.apply({a:2})()
// Object {a:2}
// Object {a:2}
```
通过这段代码，我们应该可以明确的看出来，箭头函数是直接使用的它词法作用域内的`this`，也就是定义它时的作用域内的`this`。当我们修改它的作用域内的`this`值，也就是`func`的`this`值时，在箭头函数内也可以反映出来。用作对比，我们看下使用`function`定义的函数：
```javascript
function func() {
    console.log(this)
    return function(){
        console.log(this)
    }
};

func()()

func.apply({a:1})()

func.apply({a:2})()
```
想一下，这段函数的输出应该是什么，回顾下我们前面提到的：
>在函数执行时，this 关键字并不会指向正在运行的函数本身，而是指向调用该函数的对象。

那么在这里，不管函数`func`内的`this`究竟是指向哪里，但是**调用**`func`返回的匿名函数的对象是`window`。这里需要明白，函数也是**值**，`func`只是返回了一个值，最终调用这个值的对象实际是**`window`**。所以，这里的控制台的打印结果应该是：
```javascript
Window
Window

Object {a: 1}
Window

Object {a: 2}
Window
```
即匿名函数的`this`值是指向的`window`。跟上面的箭头函数的结果做对比，是不是对箭头函数**拥有词法作用域的this值**，理解更深了呢？
## 小结
此时再来看看我们的[引入](#引入)里面的问题，为什么`Object`内使用箭头函数定义的方法，在使用`Object`调用时，箭头函数内的`this`无法访问到`Object`对象？原因还是我们那句话：**使用词法作用域内的`this`**。`Object`对象是不会新建自己的`this`值的，所以箭头函数会一直使用词法作用域内的`this`，也就是`window`。
## 后记
箭头函数的出现使的在 JavaScript 中的`this`值更加符合我们的预期，避免了一些意料之外的问题出现。但是某些时候，例如说在`Object`里定义的函数，使用方法调用时不会使用调用它的对象作为`this`值。所以，我们应该理解箭头函数和普通定义的函数的区别，正确的使用他们。