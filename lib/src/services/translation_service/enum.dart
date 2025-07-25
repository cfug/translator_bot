/// 文本结构类型
enum TextStructureType {
  none,

  /// 空行
  blankLine,

  /// 段落（除其他类型以外无法判定的内容）
  paragraph,

  /// 顶部元数据（第 1 行开始的元数据）
  /// ```
  /// ---
  /// xxx: xxx
  /// ---
  /// ```
  topMetadata,

  /// Markdown 标题 `# xxx`
  markdownTitle,

  /// Markdown 列表项 `* xxx`、`- xxx`、`1. xxx`
  markdownListItem,

  /// markdown 图片 `![xxx](xxx)`
  markdownImage,

  /// Markdown 定义的链接 `[xx]: xxx`
  markdownDefineLink,

  /// Markdown 分割横线 `---`、`- - -`、`* * *`、`_ _ _`
  markdownHorizontalRule,

  /// Markdown 代码块
  /// ```
  /// ```dart
  /// xxx
  /// ```
  /// ```
  markdownCodeBlock,

  /// Markdown 表格
  markdownTable,

  /// Markdown 自定义 aside/admonition 语法（存在类型）
  ///
  /// - `:::类型`
  markdownCustomAsideType,

  /// Markdown 自定义 aside/admonition 语法（存在类型、标题）
  ///
  /// - `:::类型 标题`
  markdownCustomAsideTypeTitle,

  /// Markdown 自定义 aside/admonition 语法（仅 ::: 表结束）
  ///
  /// - `:::`
  markdownCustomAsideEnd,

  /// Markdown 自定义语法 `{:xxx}`
  markdownCustom1,

  /// Markdown 自定义语法  `<?xxx`
  markdownCustom2,

  /// Liquid 语法1 `{%`
  liquid1,

  /// HTML 标签 `<xxx`、`</xxx`
  htmlTag,

  /// HTML 注释 `<!-- xx -->`
  htmlComment,

  /// 中文 - 段落
  chineseParagraph,

  /// 中文 - 顶部元数据
  chineseTopMetadata,

  /// 中文 - Markdown 标题 `# xxx`
  chineseMarkdownTitle,

  /// 中文 - Markdown 列表项 `* xxx`、`- xxx`、`1. xxx`
  chineseMarkdownListItem,

  /// 中文 - Markdown 表格
  chineseMarkdownTable,

  /// 中文 - Markdown 自定义 aside/admonition 语法（存在类型、标题）
  ///
  /// - `:::类型 标题`
  chineseMarkdownCustomAsideTypeTitle,

  /// 中文 - Liquid 语法1 `{%`
  chinsesLiquid1;

  bool get isChinese => [
    TextStructureType.chineseParagraph,
    TextStructureType.chineseTopMetadata,
    TextStructureType.chineseMarkdownTitle,
    TextStructureType.chineseMarkdownListItem,
    TextStructureType.chineseMarkdownTable,
    TextStructureType.chineseMarkdownCustomAsideTypeTitle,
    TextStructureType.chinsesLiquid1,
  ].contains(this);
}
