---
title: 理解 JavaScript 中的 macrotask 和 microtask 的区别
categories:
tags:
---

# 前言
在实现 Promise/A+ 库的过程中，第一次听说了 JavaScript 中的 macrotask 和 microtask 的概念。然后 Google 搜索到了以下的资料:
- [difference-between-microtask-and-macrotask-within-an-event-loop-context](https://stackoverflow.com/questions/25915634/difference-between-microtask-and-macrotask-within-an-event-loop-context#)
- [Tasks, microtasks, queues and schedules](https://jakearchibald.com/2015/tasks-microtasks-queues-and-schedules/)

阅读之后结合我自己的理解，来说说这两者的区别。

# 异步任务运行机制
>   [阮一峰 - JavaScript 运行机制详解：再谈Event Loop](http://www.ruanyifeng.com/blog/2014/10/event-loop.html)
    [Philip Roberts - Help,I'm stuck in an event loop](http://v.youku.com/v_show/id_XODA0MDYyNTcy.html)
    
在那之前，我们先说一说 JavaScript 中的事件机制，上面两个链接中的文章和视频非常详细的解释了该机制。我们只简单的解释一下，先运行下面的一段代码:

```javascript
console.log('script start');

setTimeout(function() {
  console.log('setTimeout');
}, 0);

console.log('script end');
```

此段代码最后的输出结果为：
```
"script start"
"script end"
"setTimeout"
```

这是因为 JavaScript 引主线程拥有一个 **调用栈** 以及一个 **任务队列**，脚本运行时会被一行一行的解释，函数被推入栈中，当遇到 WebAPI 时（例如：`setTimeout`, `ajax`），这些异步操作会由浏览器控制，浏览器在这些任务完成后，将事先定义的回调函数推入主线程的 **任务队列** 中。

而主线程则会在 **清空当前调用栈后**，按照先入先出的顺序读取任务队列里面的任务。

这也就是为什么，上面的代码中`setTimeout(cb, 0)`会最后执行的原因， JavaScript 引擎会先将主程序中的所有代码执行完毕后再读取任务队列。

# macrotask 和 microtask

Macrotask 和 microtask 都是属于上述的异步任务中的一种，我们先看一下他们分别是哪些 API ：
- **macrotasks**: `setTimeout`, `setInterval`, `setImmediate`, I/O, UI rendering
- **microtasks**: `process.nextTick`, `Promises`, `Object.observe`, `MutationObserver`

那么我们知道了 `setTimeout` 是 macrotask ,而 `Promise` 是 microtask,那么我们通过下面的代码来展现他们的不同：

```javascript
console.log('script start');

setTimeout(function() {
  console.log('setTimeout');
}, 0);

Promise.resolve().then(function() {
  console.log('promise1');
}).then(function() {
  console.log('promise2');
});

console.log('script end');
```
 *(代码来自文章)*
最终的运行结果为：
```
script start
script end
promise1
promise2
setTimeout
```

这里的运行结果是`Promise`的异步任务会优先于`setTimeout`执行。那么我们可以假设有一个 microtask 的队列，microtask 会被推入这个优先级大于 macrotask 的队列。那么现在我们 JavaScript 运行时会拥有：
1. 主线程的 JavaScript 调用栈
2. microtask 任务队列
3. macrotask 任务队列

运行时的流程为：

```flow
st=>start: 开始执行
js=>operation: 主线程调用栈
mis=>operation: 提取一个任务到主线程调用栈
emis=>condition: microtasks是否清空？
mas=>operation: 提取一个 macrotasks 到调用栈
emas=>condition: macrotasks是否清空？
end=>end: 继续循环检测任务队列

st->js->emis
emis(no)->mis->js
emis(yes)->emas
emas(no)->mas->js
emas(yes)->end
```

简单来说，也就是我们每次都会先清空 microtask 任务队列，然后提取 **一个** macrotask 的任务，运行完之后再次清空 microtask 任务队列，再次提取 **一个** macrotask 的任务直到全部队列清空。
