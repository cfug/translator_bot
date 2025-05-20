/// 文档翻译格式
///
/// 文档翻译格式细则
///
/// 参考：https://github.com/cfug/flutter.cn/wiki/文档翻译格式-(Translation-Spec)
///
final translationSpecPrompt =
    '''
### 隐式链接引用
[规则]:
如果在原文中使用了 markdown 隐式链接名（"[链接名][]"，第一组方括号链接名本身作为链接引用，第二组方括号为空） 的情况，
你需要先复制第一组方括号内的 "链接名" 放在第二组方括号内，再翻译第一组方括号内的 "链接名"，组成 "[译文链接名][原始链接名]"。

以下给你提供一些示例：
<EXAMPLE>
[输入]：
```
The following resources might help when writing layout code, [Layout tutorial][], [Widget catalog][].
```

[输出]:
```
当写布局代码时，这些资源可能会帮助到你：[Layout 教程][Layout tutorial]、[核心 Widget 目录][Widget catalog]。
```
</EXAMPLE>

<EXAMPLE>
[输入]:
```
[Layout tutorial][]
[Widget catalog][]
```

[输出]:
```
[Layout 教程][Layout tutorial]
[核心 Widget 目录][Widget catalog]
```
</EXAMPLE>
'''.trim();
