---
title: 前端基础知识整理
categories:
    - 前端
tags:
    - 知识整理
date: 2017-4-20 16:12:07
---
# 前端基础知识
## Node
### 概述
### API
#### Node.nodeName
##### 概述
返回当前节点的节点名称。
##### 关键点
使用以下代码：
```javascript
<div id="d1">hello world</div>
<input type="text" id="t"/>
var div = document.getElementById("d1");
var input = document.getElementById("t");
```
- `div.nodeName` 等于 `div.tagName`，为 `DIV`（在 HTML 文档中）。
- 对于 `div.childNodes[0]`，即 `hello world` 字符串，该节点为文本节点，不属于 `Element`，所以不具有 `tagName` 属性，即 `tagName` 为：`undefined`。此时，`nodeName`为：`#text`。
##### 基本值
`nodeName` 基本值为以下：
- `#comment`：HTML 标签之间的注释信息。
- `#script`：脚本节点。
- `#text`：文本节点。
- *`Element`*：HTML 的元素名，例如：`DIV`、`INPUT`、`HEAD`等。
#### Node.nodeValue
##### 概述
返回或设置当前节点的值
##### 关键点
- 对于文本或注释节点，返回其文本内容，可通过设置该值改变内容。
- 对于 HTML 元素节点，返回 `null`，赋值无效。
#### Node.childNodes
##### 对于文本节点的特殊处理
示例代码：
```html
<p id="p">
  <span>hello</span>
</p>
```
```javascript
var p = document.getElementById("p")
console.log(p.childNodes)
```
对于该 HTML 文档，`P` 元素将会有 3 个子节点，原因是**任意多个的空白符都将导致文本节点的插入，包括一个到多个空格符、换行符、制表符等等。**在这里，`span` 元素之前，有换行，以及空格，这些文本会被作为一个新的文本节点，`span` 元素之后的换行也会作为一个文本节点。

那么是不是删除空白符号，节点就会是只有一个 `span`。更改 HTML 代码为：
```html
<p id="p"><span>hello</span></p>
```
此时，在查看 `p` 的 `childNodes` ，就会只有一个，并且 `nodeName` 为 `SPAN`。
##### 与 Element.children 的区别
- `Node.childNodes` 返回包含指定节点的子节点的集合，该集合包含文本节点。
- `Element.children` 只包含 HTML 元素。

运行以下代码：
```javascript
var el = document.createElement("div");
el.textContent = "foo"
el.childNodes.length === 1; // TextNode is a node child
el.children.length === 0; // no Element children
```
#### Node.textContent
##### 概述
表示一个节点及其后代的文本内容，会将子节点所有的 `textContent` 合并后返回。
##### 示例代码
##### 与 Node.innerText 的区别
示例代码，来自[INNERTEXT VS. TEXTCONTENT](https://kellegous.com/j/2013/02/27/innertext-vs-textcontent/)：
```javascript
<div id="t"><div>   lions,
tigers</div><div style="visibility:hidden">and bears</div></div>
```
该 `div` 节点取得的值为：
- `innerText`："lions, tigers"
- `textContent`："   lions,\ntigersand bears"

我们可以注意到 `innerText`的以下不同之处：
- 不会获取隐藏的元素中的文本（例如 `display:none` 等）。
- 不会获取我们原始输入的换行符。
- 不会获取首尾的空白字符。

以及其它的不同：
- `textContent` 会获取所有元素的内容，包括 \<script\> 和 \<style\> 元素，然而 `innerText` 不会。
- 由于 `innerText` 受 CSS 样式的影响，它会触发重排，但 `textContent` 不会。

另外，由于 `innerText` 需要获取渲染的样式信息，所以性能**远远低于** `textContent` 。在上面提到的文章中，有测试样例，耗时为（`innerText` 400ms **VS** `textContent` 2ms ）。
### 基本 API
- `Node.nodeType`：表示该节点的类型。
- `Node.nextSibling`：返回其父节点的 childNodes 列表中紧跟在其后面的节点，如果指定的节点为最后一个节点，则返回 null。

## Event
### 事件机制
#### 基本运行流程
浏览器的事件处理运行流程分为：
1. **捕获阶段**
2. **目标阶段**
3. **冒泡阶段**
### API
#### EventTarget.addEventListener  [![|20x0](https://developer.cdn.mozilla.net/static/img/opengraph-logo.dc4e08e2f6af.png)](https://developer.mozilla.org/zh-CN/docs/Web/API/EventTarget/addEventListener)
##### 概述
```
target.addEventListener(type, listener[, options]);
target.addEventListener(type, listener[, useCapture]);
```
- `useCapture`  可选
`Boolean`，是否使用捕获模式。
- `options` 可选
    一个指定有关 listener 属性的可选参数对象。可用的选项如下：
    - `capture`： `Boolean`，表示 listener 会在该类型的事件捕获阶段传播到该 `EventTarget` 时触发。
    - `once`： `Boolean`，表示 listener 在添加之后最多只调用一次。如果是 `true`， listener 会在其被调用之后自动移除。
    - `passive`： `Boolean`，表示 listener 永远不会调用 `preventDefault()`。如果 listener 仍然调用了这个函数，客户端将会忽略它并抛出一个控制台警告。
##### 关键点
- listener 函数需要保存其引用，便于删除，避免使用匿名函数。
- listener 函数中的 `this` 值默认指向当前的 `EventTarget`，若要改变该值，请使用 `bind` 绑定函数或使用箭头函数 `=>` 定义。
- 当对同一事件注册多个相同的 listener 时，重复实例会被抛弃。比较方法为比较引用，与 `removeEventListener` 使用的方法相同。
- 使用匿名函数还会造成内存消耗过多。
##### 为什么使用该 API？
- 它允许给一个事件注册多个 listener。
- 它提供了一种更精细的手段控制 listener 的触发阶段。（即可以选择捕获或者冒泡）。
- 它对任何 DOM 元素都是有效的，而不仅仅只对 HTML 元素有效。
##### 兼容性
对于 Internet Explorer 来说，在IE 9之前，你必须使用 `attachEvent` 而不是使用标准方法 `addEventListener`。为了支持 IE，你应该这么写：
```javascript
if (el.addEventListener) {
  el.addEventListener('click', modifyText, false); 
} else if (el.attachEvent)  {
  el.attachEvent('onclick', modifyText);
}
```
#### Event.target
##### 概述
指向触发事件的对象。当事件处理程序在冒泡阶段或者捕获阶段调用的时候，该目标对象与 event.currentTarget 不同。（通俗点解释就是，只有当绑定的事件处理程序与触发该事件处理程序都为同一个对象的时候，两者相同。）
##### 兼容性
在 IE 5-6 中，使用 `e.srcElement` 代替 `e.target`。