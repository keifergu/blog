---
title: ES6箭头函数(arrow_function)的this值探究
date: 2016-12-06 16:10:37
tags: javascript
---
## 前言
对于ES6新增的箭头函数,相关的介绍可以查看[MDN - Arrow_functions](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Functions/Arrow_functions)。

另外，对于[ECMAScript 6 入门](http://es6.ruanyifeng.com/#docs/function#箭头函数)中关于箭头函数的一部分我有一点不同的见解。
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

## `function`定义的方法
这里我们先说为什么使用`function`定义的方法能够按照我们的预计正确读取到`i`的值。

首先，我们要明白[MDN - Functions](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Functions)：
>在函数执行时，this 关键字并不会指向正在运行的函数本身，而是指向调用该函数的对象。

那么，也就是说，我们使用`function`定义的函数，在定义时，它并不知道这个`this`会指向哪里，只有在运行的时候才能明确`this`的值。

在这里，我们是使用`obj.func`，调用函数`func`的对象是`obj`，所以函数`func`的`this`被指向调用它的对象`obj`。

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
此时调用函数`func`的是`window`对象，所以函数`func`的`this`被指向了`window`。

## 箭头函数定义的方法

接下来再来说说为什么使用箭头函数定义的方法不能访问到`obj`里的值。

首先，我们还是要明白[MDN - Arrow_functions](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Functions/Arrow_functions)：
>箭头函数拥有词法作用域的this值（即不会新产生自己作用域下的this, arguments, super 和 new.target 等对象）

箭头函数本身不具有`this`，它会直接绑定到它的作用域内的`this`，所以我们来看下面一段代码：
```javascript
function d() {
    console.log(this)
    return (() => this)()
};

console.log(d())
// Window 
// Window
console.log(d.apply({a:1}))
// Object {a:1}
// Object {a:1}
console.log(d.apply({a:2}))
// Object {a:2}
// Object {a:2}
```



