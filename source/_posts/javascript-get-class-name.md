---
title: 在Javascript中获取class的类型名的方法
date: 2016-10-20 21:29:38
tags:
---

在Javascript中获取class的类型名主要有以下几种方法：
1. `Function.name`
在JS中`class`的类型名是由`constructor`的函数名决定的，那么我们可以直接调用`constructor.name`获取到类型名，这个方法不管是对通过`new`新建的实例还是`class`对象都能适用
```javascript
class Polygon {
    constructor(){
        this.x = 1;
    }

    say() {
        console.log(this.constructor.name); //Polygon
    }
}

let p = new Polygon();
console.log(p.constructor.name); //Polygon
```
2. `class.name`
由于`class`本质只是函数的一层包装，也就是跟我们以前使用构造函数写类本质是一样的，所以我们可以直接使用`class.name`获取到类型名，但是对使用`new`新建的实例没用：
```javascript
class Polygon {
    constructor(){
    }
}
console.log(Polygon.name); //Polygon
```
3. `toString`与正则表达式
因为现在`Function.name`还不是正式的标准，MDN不推荐在生产环境使用，详见[Function.name](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Function/name)，所以在较低的版本最好的办法是使用`Function.toString()`,然后使用正则表达式匹配在`function`后面的字符。
```javascript
function Polygon() {
    this.x = 1;
}
class Circle {
    constructor() {
    }
}
var nameFromToStringRegex = /^function\s?([^\s(]*)/;
var funName = Polygon.toString().match(nameFromToStringRegex)[1];
console.log(funName); //Polygon
var className = Circle.constructor.toString().match(nameFromToStringRegex)[1];
console.log(className);
```
4. 通用的方法
适用与`function`与`class`的类名，函数名的获取。
摘自[stackoverflow](http://stackoverflow.com/questions/3178892/get-function-name-in-javascript)：
```javascript
/**
 * Gets the classname of an object or function if it can.  Otherwise returns the provided default.
 *
 * Getting the name of a function is not a standard feature, so while this will work in many
 * cases, it should not be relied upon except for informational messages (e.g. logging and Error
 * messages).
 *
 * @private
 */
function className(object, defaultName) {
    var nameFromToStringRegex = /^function\s?([^\s(]*)/;
    var result = "";
    if (typeof object === 'function') {
        result = object.name || object.toString().match(nameFromToStringRegex)[1];
    } else if (typeof object.constructor === 'function') {
        result = className(object.constructor, defaultName);
    }
    return result || defaultName;
}
```