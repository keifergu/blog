---
title: Rangy 使用指南
categories:
  - 前端
tags:
  - JavaScript
date: 2017-03-16 15:42:18
---


# 前言

 [Rangy](https://github.com/timdown/rangy) 是一个跨浏览器的对 Selection 和 Range 进行操作的 JavaScript 库，可以实现很多非常酷炫的功能，例如：
 - 将当前的托选操作储存，取消托选后，根据储存的值让上一步的内容重新被选中
 - 将文本的高亮编码为字符串，刷新网页后根据该字符串重新对对应文本进行高亮操作
 
可以在这里查看 [在线演示](http://lezuse.github.io/rangy/demos/)，对所有的功能进行一个浏览，特别是它的 Save/Restore 模块，非常的 Coooool!

完整的文档在 [Github Wiki](https://github.com/timdown/rangy/wiki/)，本文将会简单的介绍它的使用，如果需要更详细的说明，请查看文档。

# 安装、使用

 Rangy 提供了 npm 包 和 bower 包，或者你可以直接在 [Github仓库](https://github.com/timdown/rangy/tree/master/lib) 下载它的 lib 文件。

 使用 npm 安装：
 `npm i rangy -S`

 使用的时候需要像如下方式引用：
 ```javascript
    import rangy from 'rangy';
    import rangyTextRange from 'rangy/lib/rangy-textrange';
    import rangyHighlighter from 'rangy/lib/rangy-highlighter';
    import rangySerializer from 'rangy/lib/rangy-serializer';
    import rangyClassApplier from 'rangy/lib/rangy-classapplier';
    import rangySaveRestore from 'rangy/lib/rangy-selectionsaverestore';
 ```
 你可以根据自己的实际需求引入其中特定的包，现在你就可以在你的项目中使用它了。

 如果我们想最简单的尝试一下，就新建一个网页，然后从 Github 引入它的库文件:
 ```html
<!DOCTYPE html>
<html lang="en">
<head>
   <meta charset="UTF-8">
   <title>rangy</title>
   <style type="text/css">
       .highlight {
            background-color: yellow;
        }
   </style>
   <script src="https://rawgit.com/timdown/rangy/master/lib/rangy-core.js"></script>
   <script src="https://rawgit.com/timdown/rangy/master/lib/rangy-classapplier.js"></script>
   <script src="https://rawgit.com/timdown/rangy/master/lib/rangy-highlighter.js"></script>
   <script src="https://rawgit.com/timdown/rangy/master/lib/rangy-selectionsaverestore.js"></script>
   <script src="https://rawgit.com/timdown/rangy/master/lib/rangy-serializer.js"></script>
   <script src="https://rawgit.com/timdown/rangy/master/lib/rangy-textrange.js"></script>
</head>
<body>
   <p>这是一段文本</p>
   <p>这是一段文本</p>
   <script type="text/javascript">
       console.log(rangy.version)
   </script>

</body>
</html>
 ```

 当我们打开这个网页，会看到控制台输出了：
 `1.3.1-dev`
 这就说明 rangy 已经加载完成，后面我们所有的代码都可以在 `rangy.version` 这行下面完成，也可以直接在控制台里面进行操作。

# 基本使用
## 获取文本
 操作： 用鼠标选中网页中的一段文字
 输入代码： `rangy.getSelection().toString()`
 结果： 返回你选中的文本

 使用 `rangy.getSelection()` 可以获的一个包装后的标准 Selection 对象，标准对象拥有的方法它都具有，具体文档请移步 [MDN - Selection](https://developer.mozilla.org/zh-CN/docs/Web/API/Selection)

## 使用样式高亮所选文本
 操作： 用鼠标选中网页中的一段文字
 添加 CSS 样式：
    注意，我们已经在 HTML 文件中添加了 `.highlight` 样式，此处的高亮即是使用这个样式
 输入代码：
 ```javascript
 var highlighter;
 highlighter = rangy.createHighlighter();
 highlighter.addClassApplier(rangy.createClassApplier("highlight", {
     ignoreWhiteSpace: true,
     tagNames: ["span"]
 }));
 highlighter.highlightSelection("highlight");
 ```
 这段代码先是创建了一个 `Highlighter`  对象，这个对象封装了所有高亮相关的操作，然后在内部添加一个 `ClassApplier` , `ClassApplier` 则是一个替换规则，定义高亮的时候使用哪种样式去对选中的文本进行替换，以及替换的元素等。

 最后调用 `highlightSelection` 方法，传入样式参数，该参数也就是你在第3行定义的`class`

## 其它功能
 其它功能可以在 [在线演示](http://lezuse.github.io/rangy/demos/) 中进行查看，然后下载 [Rangy 源码](https://github.com/timdown/rangy)，在其中的 demos 文件夹查看具体实现。