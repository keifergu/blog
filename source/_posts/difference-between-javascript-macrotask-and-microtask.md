---
title: 异步 JavaScript 之理解 macrotask 和 microtask
date: 2017-03-23 22:35:17
categories:
    - 异步 JavaScript
tags:
    - JavaScript
    - 前端
---
本文详细解释了 JavaScript 的事件循环机制，以及其任务队列的工作模式。重点是根据 HTML5 标准，对 macrotask 和 microtask 的区别进行了阐述。
<!-- more -->
# 前言
在尝试实现 Promise/A+ 库 [KPromise](github.com/keifergu/kpromise)的过程中，第一次听说了 JavaScript 中的 macrotask 和 microtask 的概念。然后 Google 搜索到了以下的资料:

- [difference-between-microtask-and-macrotask-within-an-event-loop-context](https://stackoverflow.com/questions/25915634/difference-between-microtask-and-macrotask-within-an-event-loop-context#)
- [Tasks, microtasks, queues and schedules][jake]
[jake]: https://jakearchibald.com/2015/tasks-microtasks-queues-and-schedules/


阅读之后结合我自己的理解，来说一说浏览器的事件循环机制，以及 microtask 在其中扮演了什么样的角色。

# 异步任务运行机制

>   [阮一峰 - JavaScript 运行机制详解：再谈Event Loop](http://www.ruanyifeng.com/blog/2014/10/event-loop.html)
>  
>   [Philip Roberts - Help,I'm stuck in an event loop](http://v.youku.com/v_show/id_XODA0MDYyNTcy.html)
    
在那之前，我们先说一说 JavaScript 中的事件循环机制，上面两个链接中的文章和视频非常详细的解释了该机制。我们只简单的解释一下，先运行下面的一段代码:

```javascript
console.log('script start');

setTimeout(function() {
  console.log('setTimeout');
}, 0);

console.log('script end');
```

这里一看，`setTimeout`的延时为 0 ，那么是不是程序执行到这里之后就立即执行`setTimeout`里面的函数呢？其实不是的，此段代码最后的输出结果为：
```
"script start"
"script end"
"setTimeout"
```

这是因为 JavaScript 主线程拥有一个 **执行栈** 以及一个 **任务队列**，主线程会依次执行代码，当遇到函数时，会先将函数 **入栈**，函数运行完毕后再将该函数 **出栈**，直到所有代码执行完毕。

那么遇到 WebAPI（例如：`setTimeout`, `AJAX`）这些函数时，这些函数会立即返回一个值，从而让主线程不会在此处阻塞。而真正的异步操作会由浏览器执行，浏览器会在这些任务完成后，将事先定义的回调函数推入主线程的 **任务队列** 中。

而主线程则会在 **清空当前执行栈后**，按照先入先出的顺序读取任务队列里面的任务。

那么我们来看一下上面程序的执行顺序：
```javascript
// 1. 开始执行
console.log('script start'); // 2. 打印字符串 "script start"

setTimeout(
    function() {                 // 5. 浏览器在 0ms 之后将该函数推入任务队列
                                 //    而到第5步时才会被主线程执行
      console.log('setTimeout'); // 6. 打印字符串 "setTimeout"
    },
    0
);                       // 3. 调用 setTimeout 函数，并定义其完成后执行的回调函数

console.log('script end');   // 4. 打印字符串 "script end"

// 5. 主线程执行栈清空，开始读取 任务队列 中的任务
```

以上就是浏览器的异步任务的执行机制，核心点为：
- 异步任务是由浏览器执行的，不管是`AJAX`请求，还是`setTimeout`等 API，浏览器内核会在其它线程中执行这些操作，当操作完成后，将操作结果以及事先定义的回调函数放入 JavaScript 主线程的任务队列中
- JavaScript 主线程会在执行栈清空后，读取任务队列，读取到任务队列中的函数后，将该函数入栈，一直运行直到执行栈清空，再次去读取任务队列，不断循环
- 当主线程阻塞时，任务队列仍然是能够被推入任务的。这也就是为什么当页面的 JavaScript 进程阻塞时，我们触发的点击等事件，会在进程恢复后依次执行。

# Macrotasks 和 Microtasks

## 基本介绍
Macrotask 和 microtask 都是属于上述的异步任务中的一种，我们先看一下他们分别是哪些 API ：
- **macrotasks**: `setTimeout`, `setInterval`, `setImmediate`, I/O, UI rendering
- **microtasks**: `process.nextTick`, `Promises`, `Object.observe`(废弃), `MutationObserver`

 `setTimeout` 的 macrotask ,和 `Promise` 的 microtask 有什么不同呢？ 我们通过下面的代码来展现他们的不同点：

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
*（代码来自 [Tasks, microtasks, queues and schedules][jake]，原文有执行顺序的可视化操作演示，推荐观看）*

在这里，`setTimeout`的延时为0，而`Promise.resolve()`也是返回一个被`resolve`了`promise`对象，即这里的`then`方法中的函数也是相当于异步的立即执行任务，那么他们到底是谁在前谁在后？

我们看看最终的运行结果（node 7.7.3)：
```javascript
"script start"
"script end"
"promise1"
"promise2"
"setTimeout"
```

这里的运行结果是`Promise`的立即返回的异步任务会优先于`setTimeout`延时为0的任务执行。

原因是任务队列分为 macrotasks 和 microtasks，而`Promise`中的`then`方法的函数会被推入 microtasks 队列，而`setTimeout`的任务会被推入 macrotasks 队列。**在每一次事件循环中，macrotask 只会提取一个执行，而 microtask 会一直提取，直到 microtasks 队列清空**。

**注：一般情况下，macrotask queues 我们会直接称为 task queues，只有 microtask queues 才会特别指明。**

那么也就是说如果我的某个 microtask 任务又推入了一个任务进入  microtasks 队列，那么在主线程完成该任务之后，仍然会继续运行 microtasks 任务直到任务队列耗尽。

**而事件循环每次只会入栈一个 macrotask ，主线程执行完该任务后又会先检查 microtasks 队列并完成里面的所有任务后再执行 macrotask**

## 事件循环进程模型
现在我们根据 [HTML Standard - event loop processing model](https://html.spec.whatwg.org/multipage/webappapis.html#event-loop-processing-model)来描述浏览器的事件循环的进程模型：
1. 选择最先进入 *事件循环任务队列*的一个任务， 如果队列中没有任务，则直接跳到第6步的 *Microtask*
2. 设置 *事件循环的当前运行任务*为上一步所选择的任务
3. *Run*: 运行所选任务
4. 设置 *事件循环的当前运行任务*为 null
5. 将刚刚第3步运行的任务从它的任务队列中删除
6. *Microtasks*:  *perform a microtask checkpoint*
7. 更新并渲染界面
8. 返回第1步

*perform a microtask checkpoint* 的执行步骤:
1. 设置 *performing a microtask checkpoint* 的标记为 true
2. *Microtask queue handling*: 如果事件循环的 microtask queue 是空，跳到第8步 *Done*
3. 选取最先进入 microtask queue 的 microtask
4. 设置 *事件循环的当前运行任务* 为上一步所选择的任务
5. *Run*: 执行所选取的任务
6. 设置 *事件循环的当前运行任务* 为 null
7. 将刚刚第5步运行的 microtask 从它的 microtask queue 中删除
8. *Done*: For each environment settings object whose responsible event loop is this event loop, notify about rejected promises on that environment settings object *（此处建议查看原网页）*
9. 清理 Index Database 的事务
10. 使 *performing a microtask checkpoint* 的标记为 false

在我们的浏览器环境的事件循环中， JavaScript 脚本也会作为一个 task 被推入 task queue，我们在运行这个事件后，该脚本中的 microtasks，tasks 才会被推入队列。

<!-- ```flow
st=>start: 开始执行
js=>operation: 主线程执行栈
mis=>operation: 提取一个任务到执行栈
emis=>condition: microtasks是否清空？
mas=>operation: 提取一个任务到执行栈
emas=>condition: macrotasks是否清空？
end=>end: 继续循环检测任务队列

st->js->emis
emis(no)->mis->js
emis(yes)->emas
emas(no)->mas->js
emas(yes)->end
``` -->

# Microtask 的应用

> [Vue 中如何使用 MutationObserver 做批量处理 - 顾轶灵的回答](http://zhihu.com/question/55364497/answer/144215284)

> 为啥要用 microtask？根据 HTML Standard，在每个 task 运行完以后，UI 都会重渲染，那么在 microtask 中就完成数据更新，当前 task 结束就可以得到最新的 UI 了。反之如果新建一个 task 来做数据更新，那么渲染就会进行两次。


根据我们上面提到的事件循环进程模型，每一次执行 task 后，然后执行 microtasks queue，最后进行页面更新。如果我们使用 task 来设置 DOM 更新，那么效率会更低。而 microtask 则会在页面更新之前完成数据更新，会得到更高的效率。


# Microtask 的实现

>[immediate](https://github.com/calvinmetcalf/immediate) 库是一个跨浏览器的 microtask 实现。

这个库使用原生 JavaScript 实现了能够兼容 IE6 的 microtask ，如果对实现机制比较感兴趣的可以去阅读这个库的源码，我后面会写一篇文章来详细的介绍一下其实现。