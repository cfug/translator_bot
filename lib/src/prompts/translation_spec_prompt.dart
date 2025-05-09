/// 文档翻译格式
///
/// 文档翻译格式细则
///
/// 参考：https://github.com/cfug/flutter.cn/wiki/文档翻译格式-(Translation-Spec)
///
final translationSpecPrompt =
    '''
以下每项规则，你应全部结合综合考虑。

### 顶部元数据
[规则]:
原始内容顶部的元数据在 "---" 内，应注释原始行，并紧接着进行翻译，翻译应保留元数据属性。

以下给你提供一些示例：
<EXAMPLE>
[输入的原文片段]:
```
---
title: Navigate to a new screen and back
description: How to navigate between routes
prev:
  title: Animating a Widget across screens
  path: /docs/cookbook/navigation/hero-animations
next:
  title: Navigate with named routes
  path: /docs/cookbook/navigation/named-routes
---
```

[应对原文输出的片段]:
```
---
# title: Navigate to a new screen and back
title: 导航到一个新页面和返回
# description: How to navigate between routes
description: 如何进行路由导航
prev:
# title: Animating a Widget across screens
  title: 跨页面切换的动效 Widget (Hero animations)
  path: /docs/cookbook/navigation/hero-animations
next:
# title: Navigate with named routes
  title: 导航到对应名称的 routes 里
  path: /docs/cookbook/navigation/named-routes
---
```
</EXAMPLE>

<EXAMPLE>
[输入的原文片段]:
```
---
title: Navigate to a new screen and back
description: >-
           How to navigate between routes
prev:
  title: Animating a Widget across screens
  path: /docs/cookbook/navigation/hero-animations
next:
  title: Navigate with named routes
  path: /docs/cookbook/navigation/named-routes
---
```

[应对原文输出的片段]:
```
---
# title: Navigate to a new screen and back
title: 导航到一个新页面和返回
# description: >-
#           How to navigate between routes
description: >-
            如何进行路由导航
prev:
# title: Animating a Widget across screens
  title: 跨页面切换的动效 Widget (Hero animations)
  path: /docs/cookbook/navigation/hero-animations
next:
# title: Navigate with named routes
  title: 导航到对应名称的 routes 里
  path: /docs/cookbook/navigation/named-routes
---
```
</EXAMPLE>

### 标题、通常的段落内容
[规则]:
如果是标题、通常的段落内容，应将译文放在原文下方，原文与译文之间应空一行，译文下方应空一行，
如果原文中使用了 markdown 链接引用，译文应以 markdown "[译文][原文的链接引用]" 形式进行翻译。

以下给你提供一些示例：
<EXAMPLE>
[输入的原文片段]:
```
## Overview

The core of Flutter's layout mechanism is widgets.
In Flutter, almost everything is a widget&mdash;even
layout models are widgets. The images, icons,
and text that you see in a Flutter app are all widgets.
But things you don't see are also widgets,
such as the rows, columns, and grids that arrange,
constrain, and align the visible widgets.
You create a layout by composing widgets to build more
complex widgets.
```

[应对原文输出的片段]:
```
## Overview

## 概览

The core of Flutter's layout mechanism is widgets.
In Flutter, almost everything is a widget&mdash;even
layout models are widgets. The images, icons,
and text that you see in a Flutter app are all widgets.
But things you don't see are also widgets,
such as the rows, columns, and grids that arrange,
constrain, and align the visible widgets.
You create a layout by composing widgets to build more
complex widgets.

Flutter 布局的核心机制是 widget。
在 Flutter 中，几乎所有东西都是 widget &mdash; 甚至布局模型都是 widget。
你在 Flutter 应用程序中看到的图像，图标和文本都是 widget。
此外不能直接看到的也是 widget，
例如用来排列、限制和对齐可见 widget 的行、列和网格。

```
</EXAMPLE>

<EXAMPLE>
[输入的原文片段]:
```
The [Material library][] implements widgets that follow [Material
Design][] principles. When designing your UI, you can exclusively use
widgets from the standard [widgets library][], or you can use
widgets from the Material library. You can mix widgets from both
libraries, you can customize existing widgets,
or you can build your own set of custom widgets.
```

[应对原文输出的片段]:
```
The [Material library][] implements widgets that follow [Material
Design][] principles. When designing your UI, you can exclusively use
widgets from the standard [widgets library][], or you can use
widgets from the Material library. You can mix widgets from both
libraries, you can customize existing widgets,
or you can build your own set of custom widgets.

[Material 库][Material library] 实现了一些遵循 [Material Design][] 原则的 widget。
在设计 UI 时，你可以只使用标准 [widget 库][widgets library] 中的 widget，
也可以使用 Material 库中的 widget。
你可以混合来自两个库的 widget，
可以自定义现有 widget，也可以构建自己的一组自定义 widget。

```
</EXAMPLE>

### markdown 列表语法（"-"、"*"、"1. " 等）
[规则]:
列表语法的每个项应作为单独的原文段落，应将每个项的译文放在对应原文项的下方，
原文项与译文项之间应空一行，译文项下方应空一行，译文项应与后方的原文项保持一行的距离，
译文项应避免书写原文项的列表语法符号，译文项应通过缩进与原文项的内容进行对齐。

以下给你提供一些示例：
<EXAMPLE>
[输入的原文片段]:
```
- one
- two
- three
```

[应对原文输出的片段]:
```
- one

  一

- two

  二

- three

  三

```
</EXAMPLE>

<EXAMPLE>
[输入的原文片段]:
```
* one
* two
* three
```

[应对原文输出的片段]:
```
* one

  一

* two

  二

* three

  三

```

[应避免对原文输出的片段]:
```
* one
* two
* three

* 一
* 二
* 三

```
</EXAMPLE>

<EXAMPLE>
[输入的原文片段]:
```
* **Hot reload** loads code changes into the VM and re-builds
  the widget tree, preserving the app state;
  it doesn't rerun `main()` or `initState()`.
  (`⌘` in Intellij and Android Studio, `⌃F5` in VSCode)
* **Hot restart** loads code changes into the VM,
  and restarts the Flutter app, losing the app state.
  (`⇧⌘` in IntelliJ and Android Studio, `⇧⌘F5` in VSCode)
* **Full restart** restarts the iOS, Android, or web app.
  This takes longer because it also recompiles the
  Java / Kotlin / Objective-C / Swift code. On the web,
  it also restarts the Dart Development Compiler.
  There is no specific keyboard shortcut for this;
  you need to stop and start the run configuration.
```

[应对原文输出的片段]:
```
* **Hot reload** loads code changes into the VM and re-builds
  the widget tree, preserving the app state;
  it doesn't rerun `main()` or `initState()`.
  (`⌘` in Intellij and Android Studio, `⌃F5` in VSCode)

  **热重载** 会将代码更改转入 VM，重建 widget 树并保持应用的状态，
  整个过程不会重新运行 `main()` 或者 `initState()`。
  （在 IDEA 中的快捷键是 `⌘`，在 VSCode 中是 `⌃F5`）

* **Hot restart** loads code changes into the VM,
  and restarts the Flutter app, losing the app state.
  (`⇧⌘` in IntelliJ and Android Studio, `⇧⌘F5` in VSCode)

  **热重启** 会将代码更改转入 VM，重启 Flutter 应用，不保留应用状态。
  （在 IDEA 中的快捷键是 `⇧⌘`，在 VSCode 中是 `⇧⌘F5`）

* **Full restart** restarts the iOS, Android, or web app.
  This takes longer because it also recompiles the
  Java / Kotlin / Objective-C / Swift code. On the web,
  it also restarts the Dart Development Compiler.
  There is no specific keyboard shortcut for this;
  you need to stop and start the run configuration.

  **完全重启** 将会完全重新运行应用。
  该进程较为耗时，因为它会重新编译原生部分
  (Java / Kotlin / Objective-C / Swift) 代码。
  在 Web 平台上，它同时会重启 Dart 开发编译器。
  完全重启并没有既定的快捷键，你需要手动停止后重新运行。

```

[应避免对原文输出的片段]:
```
* **Hot reload** loads code changes into the VM and re-builds
  the widget tree, preserving the app state;
  it doesn't rerun `main()` or `initState()`.
  (`⌘` in Intellij and Android Studio, `⌃F5` in VSCode)
* **Hot restart** loads code changes into the VM,
  and restarts the Flutter app, losing the app state.
  (`⇧⌘` in IntelliJ and Android Studio, `⇧⌘F5` in VSCode)
* **Full restart** restarts the iOS, Android, or web app.
  This takes longer because it also recompiles the
  Java / Kotlin / Objective-C / Swift code. On the web,
  it also restarts the Dart Development Compiler.
  There is no specific keyboard shortcut for this;
  you need to stop and start the run configuration.

* **热重载** 会将代码更改转入 VM，重建 widget 树并保持应用的状态，
  整个过程不会重新运行 `main()` 或者 `initState()`。
  （在 IDEA 中的快捷键是 `⌘`，在 VSCode 中是 `⌃F5`）
* **热重启** 会将代码更改转入 VM，重启 Flutter 应用，不保留应用状态。
  （在 IDEA 中的快捷键是 `⇧⌘`，在 VSCode 中是 `⇧⌘F5`）
* **完全重启** 将会完全重新运行应用。
  该进程较为耗时，因为它会重新编译原生部分
  (Java / Kotlin / Objective-C / Swift) 代码。
  在 Web 平台上，它同时会重启 Dart 开发编译器。
  完全重启并没有既定的快捷键，你需要手动停止后重新运行。

```
</EXAMPLE>

<EXAMPLE>
[输入的原文片段]:
```
* [Layout tutorial][]
* [Widget catalog][]
```

[应对原文输出的片段]:
```
* [Layout tutorial][]
  
  [Layout 教程][Layout tutorial]

* [Widget catalog][]
  
  [核心 Widget 目录][Widget catalog]

```

[应避免对原文输出的片段]:
```
* [Layout tutorial][]
* [Widget catalog][]

* [Layout 教程][Layout tutorial]
* [核心 Widget 目录][Widget catalog]

```
</EXAMPLE>

<EXAMPLE>
[输入的原文片段]:
```
* Lays widgets out in a grid
* Detects when the column content exceeds the render box
  and automatically provides scrolling
* Build your own custom grid, or use one of the provided grids:
  * `GridView.count` allows you to specify the number of columns
  * `GridView.extent` allows you to specify the maximum pixel
  width of a tile
```

[应对原文输出的片段]:
```
* Lays widgets out in a grid

  在网格中使用 widget

* Detects when the column content exceeds the render box
  and automatically provides scrolling

  当列的内容超出渲染容器的时候，它会自动支持滚动。

* Build your own custom grid, or use one of the provided grids:

  创建自定义的网格，或者使用下面提供的网格的其中一个：

  * `GridView.count` allows you to specify the number of columns

    `GridView.count` 允许你制定列的数量

  * `GridView.extent` allows you to specify the maximum pixel
  width of a tile
  
    `GridView.extent` 允许你制定单元格的最大宽度

```

[应避免对原文输出的片段]:
```
* Lays widgets out in a grid
* Detects when the column content exceeds the render box
  and automatically provides scrolling
* Build your own custom grid, or use one of the provided grids:
  * `GridView.count` allows you to specify the number of columns
  * `GridView.extent` allows you to specify the maximum pixel
  width of a tile

* 在网格中使用 widget
* 当列的内容超出渲染容器的时候，它会自动支持滚动。
* 创建自定义的网格，或者使用下面提供的网格的其中一个：
  * `GridView.count` 允许你制定列的数量
  * `GridView.extent` 允许你制定单元格的最大宽度
```
</EXAMPLE>

### 表格 - 表头
[规则]:
应将表头原文内容用 "<t></t>" 标签包裹，译文应同样用 "<t></t>" 标签包裹，并将译文紧贴在原文后方，形成 "<t>原文</t><t>译文</t>" 的结构格式。

以下给你提供一些示例：
<EXAMPLE>
[输入的原文片段]:
```
| one | two | three |
|---|---|---|
| xxx | xxx | xxx |
```

[应对原文输出的片段]:
```
| <t>one</t><t>一</t> | <t>two</t><t>二</t> | <t>three</t><t>三</t> |
|---|---|---|
| xxx | xxx | xxx |
```
</EXAMPLE>

### 表格 - 主体行内容
[规则]:
应将译文紧接着放在原文所在表格行的下方。

以下给你提供一些示例：
<EXAMPLE>
[输入的原文片段]:
```
| one | two | three |
|---|---|---|
| four | five | six |
| eight | nine | ten |
```

[应对原文输出的片段]:
```
| <t>one</t><t>一</t> | <t>two</t><t>二</t> | <t>three</t><t>三</t> |
|---|---|---|
| four | five | six |
| 四 | 五 | 六 |
| eight | nine | ten |
| 八 | 九 | 十 |
```
</EXAMPLE>

### HTML 内容 - 容器型块元素
[规则]:
应将译文放在原文 HTML 块元素下方，译文也应保留原文同样的 HTML 块元素，原文与译文之间应空一行，译文下方应空一行。

以下给你提供一些示例：
<EXAMPLE>
[输入的原文片段]:
```
<p>
english
</p>
```

[应对原文输出的片段]:
```
<p>
english
</p>

<p>
中文
</p>

```
</EXAMPLE>

<EXAMPLE>
[输入的原文片段]:
```
<header>
english
</header>
```

[应对原文输出的片段]:
```
<header>
english
</header>

<header>
中文
</header>

```
</EXAMPLE>

### HTML 内容 - "<div>" 块元素
[规则]:
应在 "<div>" 块内对原文进行翻译操作，"<div>" 块内应遵循翻译格式规则进行翻译。

以下给你提供一些示例：
<EXAMPLE>
[输入的原文片段]:
```
<div>english</div>
```

[应对原文输出的片段]:
```
<div>
english

中文
</div>
```
</EXAMPLE>

<EXAMPLE>
[输入的原文片段]:
```
<div>
  <img src='/assets/images/docs/ui/layout/row-spaceevenly-visual.png' alt="Row with 3 evenly spaced images">

  **App source:** [row_column]({{examples}}/layout/row_column)
</div>
```

[应对原文输出的片段]:
```
<div>
  <img src='/assets/images/docs/ui/layout/row-spaceevenly-visual.png' alt="Row with 3 evenly spaced images">

  **App source:** [row_column]({{examples}}/layout/row_column)

  **App 源码:** [row_column]({{examples}}/layout/row_column)

</div>
```
</EXAMPLE>

### HTML 内容 - "span"、"a" 块元素
[规则]:
应将译文紧贴着原文 HTML 块元素后方，译文应保留原文相同的 HTML 块元素。

以下给你提供一些示例：
<EXAMPLE>
[输入的原文片段]:
```
<span>english</span>
```

[应对原文输出的片段]:
```
<span>english</span><span>中文</span>
```
</EXAMPLE>

<EXAMPLE>
[输入的原文片段]:
```
<a href="xxx">english</a>
```

[应对原文输出的片段]:
```
<a href="xxx">english</a><a href="xxx">中文</a>
```
</EXAMPLE>

### HTML 内容 - "ol"、"li" 块元素
[规则]:
原文会以下面这种形式出现。
```
<ol markdown="1">
<li markdown="1">

english...

</li>
</ol>
```

应将译文放在块元素内的原文下方，原文与译文之间应空一行，译文下方应空一行。

以下给你提供一些示例：
<EXAMPLE>
[输入的原文片段]:
```
<ol markdown="1">
<li markdown="1">

english...

</li>
</ol>
```

[应对原文输出的片段]:
```
<ol markdown="1">
<li markdown="1">

english...

中文...

</li>
</ol>
```
</EXAMPLE>

### HTML 内容 - "dl"、"dt"、"dd" 块元素
[规则]:
原文会以下面这种形式出现，标签会含有 "markdown="1"" 属性标识：
```
<dl markdown="1">
<dt markdown="1">english</dt>
<dd markdown="1">english</dd>
</dl>
```

应将原文用 "<p markdown="1"></p>" 块包裹，译文应放在被块包裹的原文下方，译文应使用相同的 "<p markdown="1"></p>" 块包裹。

以下给你提供一些示例：
<EXAMPLE>
[输入的原文片段]:
```
<dl markdown="1">
<dt markdown="1">english</dt>
<dd markdown="1">english</dd>
</dl>
```

[应对原文输出的片段]:
```
<dl markdown="1">
<dt markdown="1">
<p markdown="1">english</p>
<p markdown="1">中文</p>
</dt>
<dd markdown="1">
<p markdown="1">english</p>
<p markdown="1">中文</p>
</dd>
</dl>
```
</EXAMPLE>

### "{% tab "标题" %}" 块语法
[规则]:
应将 "{% tab "标题" %}" 的译文放在原文下方，并修改注释原文。

以下给你提供一些示例：
<EXAMPLE>
[输入的原文片段]:
```
{% tab "Material apps" %}
```

[应对原文输出的片段]:
```
<!-- {% tab "Material apps" %} -->
{% tab "Material 应用程序" %}
```
</EXAMPLE>

### ":::" 开头的字符
[规则]:
原文中会出现以 ":::" 字符开头的内容，你应将原文 ":::" 字符开头所在行的上方和下方都空一行。

以下给你提供一些示例：
<EXAMPLE>
[输入的原文片段]:
```
:::secondary What's the point?
english1

english2
```

[应对原文输出的片段]:
```

:::secondary What's the point?

english1

英文1

english2

英文2

```
</EXAMPLE>

<EXAMPLE>
[输入的原文片段]:
```
:::secondary What's the point?
* english1
* english2
* english3
```

[应对原文输出的片段]:
```

:::secondary What's the point?

* english1

  英文1

* english2

  英文2

* english3

  英文3

```
</EXAMPLE>

<EXAMPLE>
[输入的原文片段]:
```
:::secondary
english1

english2
```

[应对原文输出的片段]:
```

:::secondary

english1

英文1

english2

英文2

```
</EXAMPLE>

<EXAMPLE>
[输入的原文片段]:
```
:::note
english1

english2
```

[应对原文输出的片段]:
```

:::note

english1

英文1

english2

英文2

```
</EXAMPLE>

<EXAMPLE>
[输入的原文片段]:
```
:::tip
english1

english2
```

[应对原文输出的片段]:
```

:::tip

english1

英文1

english2

英文2

```
</EXAMPLE>

### 链接引用
[规则]:
对于在原文中使用了 markdown 的 "[链接引用][]" ，应在原文下方翻译为 "[译文][链接引用]"，
原文与译文之间应空一行，译文下方应空一行，原文片段本身应遵循翻译格式规则。

以下给你提供一些示例：
<EXAMPLE>
[输入的原文片段]:
```
The following resources might help when writing layout code, [Layout tutorial][], [Widget catalog][].

[Layout tutorial]: /ui/layout/tutorial
[Widget catalog]: /ui/widgets
```

[应对原文输出的片段]:
```
The following resources might help when writing layout code: [Layout tutorial][], [Widget catalog][].

当写布局代码时，这些资源可能会帮助到你：[Layout 教程][Layout tutorial]、[核心 Widget 目录][Widget catalog]。

[Layout tutorial]: /ui/layout/tutorial
[Widget catalog]: /ui/widgets
```
</EXAMPLE>

<EXAMPLE>
[输入的原文片段]:
```
[Layout tutorial][]
[Widget catalog][]

[Layout tutorial]: /ui/layout/tutorial
[Widget catalog]: /ui/widgets
```

[应对原文输出的片段]:
```
[Layout tutorial][]

[Layout 教程][Layout tutorial]

[Widget catalog][]
  
[核心 Widget 目录][Widget catalog]

[Layout tutorial]: /ui/layout/tutorial
[Widget catalog]: /ui/widgets
```
</EXAMPLE>

<EXAMPLE>
[输入的原文片段]:
```
* [Layout tutorial][]
* [Widget catalog][]

[Layout tutorial]: /ui/layout/tutorial
[Widget catalog]: /ui/widgets
```

[应对原文输出的片段]:
```
* [Layout tutorial][]
  
  [Layout 教程][Layout tutorial]

* [Widget catalog][]
  
  [核心 Widget 目录][Widget catalog]

[Layout tutorial]: /ui/layout/tutorial
[Widget catalog]: /ui/widgets
```
</EXAMPLE>

### 应避免翻译 markdown 声明的链接引用
[规则]:
如果遇到 markdown 声明的链接引用 "[xxxx]: xxxx"，那就保持原文不进行翻译。

以下给你提供一些示例：
<EXAMPLE>
[输入的原文片段]:
```
The following resources might help when writing layout code, [Layout tutorial][], [Widget catalog][].

[Layout tutorial]: /ui/layout/tutorial
[Widget catalog]: /ui/widgets
```

[应对原文输出的片段]:
```
The following resources might help when writing layout code: [Layout tutorial][], [Widget catalog][].

当写布局代码时，这些资源可能会帮助到你：[Layout 教程][Layout tutorial]、[核心 Widget 目录][Widget catalog]。

[Layout tutorial]: /ui/layout/tutorial
[Widget catalog]: /ui/widgets
```
</EXAMPLE>

<EXAMPLE>
[输入的原文片段]:
```
[Layout tutorial][]
[Widget catalog][]

[Layout tutorial]: /ui/layout/tutorial
[Widget catalog]: /ui/widgets
```

[应对原文输出的片段]:
```
[Layout tutorial][]

[Layout 教程][Layout tutorial]

[Widget catalog][]
  
[核心 Widget 目录][Widget catalog]

[Layout tutorial]: /ui/layout/tutorial
[Widget catalog]: /ui/widgets
```
</EXAMPLE>

### 应避免翻译 markdown 的 "```" 代码块内的内容
[规则]:
如果遇到被 markdown 的 "```" 代码块语法包裹的内容，应保持原文不进行翻译。

以下给你提供一些示例：
<EXAMPLE>
[输入的原文片段]:
```
```console
/path-to-flutter-sdk/bin/flutter
/path-to-flutter-sdk/bin/dart
```
```

[应对原文输出的片段]:
```
```console
/path-to-flutter-sdk/bin/flutter
/path-to-flutter-sdk/bin/dart
```
```
</EXAMPLE>

<EXAMPLE>
[输入的原文片段]:
```
```
To learn more about the `dart` command, run `dart -h`
from the command line, or see the [dart tool][] page.
```
```

[应对原文输出的片段]:
```
```
To learn more about the `dart` command, run `dart -h`
from the command line, or see the [dart tool][] page.
```
```
</EXAMPLE>

### 「您」和「你」的用法
[规则]:
在文档的翻译中应避免使用「您」，应只使用「你」，以表示与开发者平等沟通的意味。

### 特殊情况1
[规则]:
如果原文有以下情况（即冒号 : 在一行的最前面的格式）：
```
标题
: 说明
```

```
english
: english
```

应将原文的 ": " 修改为 "<br>"，原文与译文之间应空一行，译文下方应空一行，译文应按照翻译格式规则进行翻译。

以下给你提供一些示例：
<EXAMPLE>
[输入的原文片段]:
```
[Layout tutorial][]
: Learn how to build a layout.
[Widget catalog][]
: Describes many of the widgets available in Flutter.
```

[应对原文输出的片段]:
```
[Layout tutorial][]
<br> Learn how to build a layout.
  
[Layout 教程][Layout tutorial]
<br> 学习如何构建布局。

[Widget catalog][]
<br> Describes many of the widgets available in Flutter.
  
[核心 Widget 目录][Widget catalog]
<br> 描述了 Flutter 中很多可用的 widget。
```
</EXAMPLE>

<EXAMPLE>
[输入的原文片段]:
```
**Layout tutorial**
: Learn how to build a layout.
**Widget catalog**
: Describes many of the widgets available in Flutter.
```

[应对原文输出的片段]:
```
**Layout tutorial**
<br> Learn how to build a layout.
  
**Layout 教程**
<br> 学习如何构建布局。

**Widget catalog**
<br> Describes many of the widgets available in Flutter.
  
**核心 Widget 目录**
<br> 描述了 Flutter 中很多可用的 widget。

```

<EXAMPLE>
[输入的原文片段]:
```
Layout tutorial
: Learn how to build a layout.
Widget catalog
: Describes many of the widgets available in Flutter.
```

[应对原文输出的片段]:
```
Layout tutorial
<br> Learn how to build a layout.
  
Layout 教程
<br> 学习如何构建布局。

Widget catalog
<br> Describes many of the widgets available in Flutter.
  
核心 Widget 目录
<br> 描述了 Flutter 中很多可用的 widget。

```
</EXAMPLE>
'''.trim();
