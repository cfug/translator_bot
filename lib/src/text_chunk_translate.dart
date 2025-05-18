import 'package:google_generative_ai/google_generative_ai.dart';

import 'reformat.dart';

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
}

class TextChunkTranslate {
  /// 文本分块翻译处理
  TextChunkTranslate(this.chat, this.text);

  /// 模型会话
  final ChatSession chat;

  /// 需要处理的原始内容
  final String text;

  /// 翻译修改后的行内容
  final List<String> modifiedLines = [];

  Future<String> run() async {
    final content = Reformat(text).all();
    final textStructureList = _parseTextStructure(content);
    await _translateTextStructure(textStructureList);
    return modifiedLines.join('\n');
  }

  /// 翻译
  Future<String> _fetchTranslate(String content) async {
    final translatedResponse = await chat.sendMessage(Content.text(content));
    final translatedText = translatedResponse.text?.trim() ?? '';
    return translatedText;
  }

  /// 处理文本结构数据（按行识别）
  ///
  /// - [content] 需要结构处理的内容
  List<TextStructure> _parseTextStructure(String content) {
    /// 内容结构的数据（可以完全还原至原始内容）
    final List<TextStructure> textStructureList = [];

    /// 当前文本结构类型
    var textStructureType = TextStructureType.none;

    /// 当前起始行
    var startLineIndex = 0;

    /// 当前结束行
    var endLineIndex = 0;

    /// 原始文本行
    List<String> originalText = [];

    /// 按行处理
    final List<String> lines = content.split('\n');
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lineTrim = line.trim();
      final lineNext = i == lines.length - 1 ? null : lines[i + 1];
      final lineNextTrim = lineNext?.trim();

      /* BEGIN 处理顶部元数据 */

      /// 顶部元数据 - 开始
      const topMetadataRegex = '---';
      if (i == 0 && lineTrim == topMetadataRegex) {
        textStructureType = TextStructureType.topMetadata;
        startLineIndex = i;
        originalText.add(line);
        continue;
      }

      /// 顶部元数据 - 结束
      if (textStructureType == TextStructureType.topMetadata &&
          i != 0 &&
          lineTrim == topMetadataRegex) {
        endLineIndex = i;
        originalText.add(line);

        /// 添加结构数据
        textStructureList.add(
          TextStructure(
            type: textStructureType,
            start: startLineIndex,
            end: endLineIndex,
            originalText: originalText,
          ),
        );

        /// 清理
        textStructureType = TextStructureType.none;
        originalText = [];
        continue;
      }

      /// 顶部元数据 - 内容
      if (textStructureType == TextStructureType.topMetadata) {
        originalText.add(line);
        continue;
      }
      /* END */

      /* BEGIN Markdown 代码块 */
      const markdownCodeBlockRegex = '```';
      if (lineTrim.startsWith(markdownCodeBlockRegex)) {
        if (textStructureType != TextStructureType.markdownCodeBlock) {
          /// Markdown 代码块 - 开始
          textStructureType = TextStructureType.markdownCodeBlock;
          startLineIndex = i;
          originalText.add(line);
        } else {
          /// Markdown 代码块 - 结束
          endLineIndex = i;
          originalText.add(line);

          /// 添加结构数据
          textStructureList.add(
            TextStructure(
              type: textStructureType,
              start: startLineIndex,
              end: endLineIndex,
              originalText: originalText,
            ),
          );

          /// 清理
          textStructureType = TextStructureType.none;
          originalText = [];
        }
        continue;
      }

      /// Markdown 代码块 - 内容
      if (textStructureType == TextStructureType.markdownCodeBlock) {
        originalText.add(line);
        continue;
      }
      /* END */

      /* BEGIN 单行空行 */
      if (lineTrim == '') {
        textStructureList.add(
          TextStructure(
            type: TextStructureType.blankLine,
            start: i,
            end: i,
            originalText: [line],
          ),
        );
        continue;
      }
      /* END */

      /* BEGIN Markdown 列表项 - 多行内容*/
      /// `* xxx`、`- xxx`、`+ xxx`、`1. xxx`
      final markdownListItemRegex = RegExp(r'^\s*([*\-+]|\d+\.)\s+(.+)$');
      if (markdownListItemRegex.hasMatch(lineTrim)) {
        /// 列表项开始
        if (textStructureType != TextStructureType.markdownListItem) {
          textStructureType = TextStructureType.markdownListItem;
          startLineIndex = i;
        }
      }
      if (textStructureType == TextStructureType.markdownListItem) {
        /// 列表项内容
        originalText.add(line);

        /// 判定是否结束列表项
        var isListItemEnd = false;
        if (lineNextTrim != null) {
          /// 下一行是否 非当前列表项内容
          final isNextLineNotCurrentText =
              lineNextTrim == '' ||
              lineNextTrim.startsWith(markdownCodeBlockRegex) ||
              markdownListItemRegex.hasMatch(lineNextTrim);

          if (isNextLineNotCurrentText) {
            isListItemEnd = true;
          }
        } else {
          isListItemEnd = true;
        }

        /// 结束列表项
        if (isListItemEnd) {
          endLineIndex = i;

          /// 添加结构数据
          textStructureList.add(
            TextStructure(
              type: textStructureType,
              start: startLineIndex,
              end: endLineIndex,
              originalText: originalText,
            ),
          );

          /// 清理
          textStructureType = TextStructureType.none;
          originalText = [];
        }
        continue;
      }
      /* END */

      /* BEGIN 单行 Markdown 标题 */
      /// `# xxx`
      final markdownTitleRegex = RegExp(r'^\s*#{1,6}\s+.+$');
      if (markdownTitleRegex.hasMatch(lineTrim)) {
        textStructureList.add(
          TextStructure(
            type: TextStructureType.markdownTitle,
            start: i,
            end: i,
            originalText: [line],
          ),
        );
        continue;
      }
      /* END */

      /* BEGIN 单行 Markdown 定义的链接 */
      /// `[xx]: xxx`
      final markdownDefineLinkRegex = RegExp(r'^\s*\[([^\]]+)\]:\s*(.+)$');
      if (markdownDefineLinkRegex.hasMatch(lineTrim)) {
        textStructureList.add(
          TextStructure(
            type: TextStructureType.markdownDefineLink,
            start: i,
            end: i,
            originalText: [line],
          ),
        );
        continue;
      }
      /* END */

      /* BEGIN 单行 Markdown 图片 */
      /// `![xxx](xxx)`
      final markdownImageRegex = RegExp(r'!\[([^\]]*)\]\s*\(\s*([^)]+)\s*\)');
      if (markdownImageRegex.hasMatch(lineTrim)) {
        textStructureList.add(
          TextStructure(
            type: TextStructureType.markdownImage,
            start: i,
            end: i,
            originalText: [line],
          ),
        );
        continue;
      }
      /* END */

      /* BEGIN 单行 Markdown 分割横线 */
      /// `---`、`- - -`、`* * *`、`_ _ _`
      final markdownHorizontalRuleRegex = RegExp(
        r'^\s*([-*_])(?:\s*\1){2,}\s*$',
      );
      if (markdownHorizontalRuleRegex.hasMatch(lineTrim)) {
        textStructureList.add(
          TextStructure(
            type: TextStructureType.markdownHorizontalRule,
            start: i,
            end: i,
            originalText: [line],
          ),
        );
        continue;
      }
      /* END */

      /* BEGIN 单行 Markdown 自定义 Aside 语法 */
      /// `:::类型 标题`
      final markdownCustomAsideRegex = RegExp(
        r'^\s*(:::)\s*([a-zA-Z0-9-]*)\s*(.*)$',
      );
      if (markdownCustomAsideRegex.hasMatch(lineTrim)) {
        final match = markdownCustomAsideRegex.firstMatch(lineTrim);
        // final delimiter = match!.group(1)!; // 必为 :::
        final type = match?.group(2)?.trim() != '' ? match?.group(2) : null;
        final title = match?.group(3)?.trim() != '' ? match?.group(3) : null;

        var textStructureType = TextStructureType.markdownCustomAsideEnd;
        if (type != null && title != null) {
          textStructureType = TextStructureType.markdownCustomAsideTypeTitle;
        } else if (type != null) {
          textStructureType = TextStructureType.markdownCustomAsideType;
        }

        textStructureList.add(
          TextStructure(
            type: textStructureType,
            start: i,
            end: i,
            originalText: [line],
          ),
        );
        continue;
      }
      /* END */

      /* BEGIN 单行 Markdown 自定义语法1 `{:xxx}` */
      /// `{:xxx}`
      final markdownCustomSyntax1Regex = RegExp(r'\{:\s*([^}]+?)\s*\}');
      if (markdownCustomSyntax1Regex.hasMatch(lineTrim)) {
        textStructureList.add(
          TextStructure(
            type: TextStructureType.markdownCustom1,
            start: i,
            end: i,
            originalText: [line],
          ),
        );
        continue;
      }
      /* END */

      /* BEGIN 单行 Markdown 自定义语法2 `<?xxx` */
      /// `<?xxx`
      final markdownCustomSyntax2Regex = RegExp(r'^\s*\<\?');
      if (markdownCustomSyntax2Regex.hasMatch(lineTrim)) {
        textStructureList.add(
          TextStructure(
            type: TextStructureType.markdownCustom2,
            start: i,
            end: i,
            originalText: [line],
          ),
        );
        continue;
      }
      /* END */

      /* BEGIN 单行 Liquid 语法 `{% xxx` */
      /// `{% xxx`
      final liquidSyntax1Regex = RegExp(r'^\s*\{%');
      if (liquidSyntax1Regex.hasMatch(lineTrim)) {
        textStructureList.add(
          TextStructure(
            type: TextStructureType.liquid1,
            start: i,
            end: i,
            originalText: [line],
          ),
        );
        continue;
      }
      /* END */

      /* BEGIN 单行 HTML 标签 `<xxx`、`</xxx` */
      /// `<xxx`、`</xxx
      final htmlTagRegex = RegExp(r'^\s*<\/?[a-zA-Z][a-zA-Z0-9-]*');
      if (htmlTagRegex.hasMatch(lineTrim)) {
        textStructureList.add(
          TextStructure(
            type: TextStructureType.htmlTag,
            start: i,
            end: i,
            originalText: [line],
          ),
        );
        continue;
      }
      /* END */

      /* BEGIN 整块段落 - 除上方其他规则以外无法判定的内容 */
      if (textStructureType != TextStructureType.paragraph) {
        /// 段落开始
        textStructureType = TextStructureType.paragraph;
        startLineIndex = i;
      }
      if (textStructureType == TextStructureType.paragraph) {
        /// 段落内容
        originalText.add(line);

        /// 判定是否结束段落
        var isParagraphEnd = false;
        if (lineNextTrim != null) {
          /// 下一行是否可判定为上方的其他类型
          final isNextLineNotParagraph =
              lineNextTrim == '' ||
              lineNextTrim.startsWith(markdownCodeBlockRegex) ||
              markdownListItemRegex.hasMatch(lineNextTrim) ||
              markdownTitleRegex.hasMatch(lineNextTrim) ||
              markdownDefineLinkRegex.hasMatch(lineNextTrim) ||
              markdownImageRegex.hasMatch(lineNextTrim) ||
              markdownHorizontalRuleRegex.hasMatch(lineNextTrim) ||
              markdownCustomAsideRegex.hasMatch(lineNextTrim) ||
              markdownCustomSyntax1Regex.hasMatch(lineNextTrim) ||
              markdownCustomSyntax2Regex.hasMatch(lineNextTrim) ||
              liquidSyntax1Regex.hasMatch(lineNextTrim) ||
              htmlTagRegex.hasMatch(lineNextTrim);

          if (isNextLineNotParagraph) {
            isParagraphEnd = true;
          }
        } else {
          isParagraphEnd = true;
        }

        /// 结束段落
        if (isParagraphEnd) {
          endLineIndex = i;

          /// 添加结构数据
          textStructureList.add(
            TextStructure(
              type: textStructureType,
              start: startLineIndex,
              end: endLineIndex,
              originalText: originalText,
            ),
          );

          /// 清理
          textStructureType = TextStructureType.none;
          originalText = [];
        }
      }
      /* END */
    }

    return textStructureList;
  }

  /// 翻译文本结构
  /// - [textStructureList] 整篇文本结构
  Future<void> _translateTextStructure(
    List<TextStructure> textStructureList,
  ) async {
    /// 最大请求数量限制
    const maxRequestLimit = 15;
    const stopRequestDuration = Duration(minutes: 1);
    var requestCount = 0;
    var chunkTotal = 0;

    /// 预计请求翻译数量
    var estimatedRequestCount = 0;
    for (var i = 0; i < textStructureList.length; i++) {
      final textStructure = textStructureList[i];
      final textStructureType = textStructure.type;
      switch (textStructureType) {
        case TextStructureType.topMetadata ||
            TextStructureType.paragraph ||
            TextStructureType.markdownTitle ||
            TextStructureType.markdownListItem ||
            TextStructureType.markdownCustomAsideTypeTitle ||
            TextStructureType.liquid1:
          estimatedRequestCount++;
        case _:
      }
    }
    print(
      '🚀 开始分块翻译 - 预计消耗时间：${estimatedRequestCount ~/ maxRequestLimit * stopRequestDuration.inMinutes} 分钟',
    );

    for (var i = 0; i < textStructureList.length; i++) {
      final textStructure = textStructureList[i];
      final textStructureType = textStructure.type;
      final textStructureNext =
          i == textStructureList.length - 1 ? null : textStructureList[i + 1];

      switch (textStructureType) {
        case TextStructureType.topMetadata:
          requestCount++;
          await _translateTopMetadata(textStructure);
        case TextStructureType.paragraph:
          requestCount++;
          await _translateMarkdownParagraph(textStructure);
          if (textStructureNext != null &&
              textStructureNext.type != TextStructureType.blankLine) {
            modifiedLines.add('');
          }
        case TextStructureType.markdownTitle:
          requestCount++;
          await _translateMarkdownTitle(textStructure);
          if (textStructureNext != null &&
              textStructureNext.type != TextStructureType.blankLine) {
            modifiedLines.add('');
          }
        case TextStructureType.markdownListItem:
          requestCount++;
          await _translateMarkdownListItem(textStructure);
          if (textStructureNext != null &&
              textStructureNext.type != TextStructureType.blankLine) {
            modifiedLines.add('');
          }
        case TextStructureType.markdownCustomAsideTypeTitle:
          requestCount++;
          await _translateMarkdownCustomAsideTypeTitle(textStructure);
          if (textStructureNext != null &&
              textStructureNext.type != TextStructureType.blankLine) {
            modifiedLines.add('');
          }
        case TextStructureType.liquid1:
          requestCount++;
          await _translateLiquidTab(textStructure);
          if (textStructureNext != null &&
              textStructureNext.type != TextStructureType.blankLine) {
            modifiedLines.add('');
          }
        case _:
          modifiedLines.addAll(textStructure.originalText);
      }

      /// 避免触发 API 请求最大限制（达到数量就暂停 1 分钟）
      if (requestCount >= maxRequestLimit) {
        chunkTotal++;
        print('📄 已处理翻译第 $chunkTotal 批（$maxRequestLimit 分块/批）');
        requestCount = 0;
        await Future.delayed(stopRequestDuration);
      }
    }
  }

  /// 翻译顶部元数据
  Future<void> _translateTopMetadata(TextStructure textStructure) async {
    final lines = textStructure.originalText;

    /// 当前正在识别的元数据属性名称
    String? currentMetadataLineName;

    /// 当前正在识别的元数据属性内容
    List<String> currentMetadataLineValue = [];

    /// 按行处理
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final lineNext = i == lines.length - 1 ? null : lines[i + 1];

      /// 顶部元数据 - 开始
      if (i == 0 && line.trim() == '---') {
        modifiedLines.add(line);
        continue;
      }

      /// 顶部元数据 - 结束
      if (i != 0 && line.trim() == '---') {
        modifiedLines.add(line);
        break;
      }

      /// 顶部元数据内容
      final metadataLine = line.split(':');
      final metadataName = metadataLine[0].trim();

      /// 当前行存在属性
      if (metadataLine.length >= 2) {
        final metadataValue = metadataLine[1].trim();

        /// 存在父属性
        if (metadataValue == '') {
          modifiedLines.add(line);
          continue;
        }

        /// 处理指定属性
        if (['title', 'short-title', 'description'].contains(metadataName)) {
          /// 注释行
          modifiedLines.add('# $line');

          /// 标注当前行
          currentMetadataLineName = metadataLine[0];
          if (metadataValue.startsWith('>-')) {
            currentMetadataLineValue.add(metadataValue.substring(2));
          } else if (metadataValue.startsWith('>')) {
            currentMetadataLineValue.add(metadataValue.substring(1));
          } else {
            currentMetadataLineValue.add(metadataValue);
          }
        } else {
          modifiedLines.add(line);
        }
      } else {
        /// 当前行不存在属性，表明为当前属性的内容
        if (currentMetadataLineName != null) {
          /// 注释行
          modifiedLines.add('# $line');
          currentMetadataLineValue.add(line.trim());
        }
      }

      /// 下一行是否存在属性/已经结束，如果存在就代表需要翻译处理当前属性内容
      final metadataLineNext = lineNext?.split(':') ?? [];
      if ((metadataLineNext.length >= 2 || lineNext?.trim() == '---') &&
          currentMetadataLineName != null) {
        /// 当前已存在属性，进行翻译处理
        final translatedText = await _fetchTranslate(
          currentMetadataLineValue.join(''),
        );
        modifiedLines.add('$currentMetadataLineName: $translatedText');

        /// 清理标注
        currentMetadataLineName = null;
        currentMetadataLineValue = [];
      }
    }
  }

  /// 翻译段落
  Future<void> _translateMarkdownParagraph(TextStructure textStructure) async {
    var lines = textStructure.originalText;

    /// 处理 `:` 开头的情况
    lines =
        lines.map((line) {
          return line.trimLeft().startsWith(':')
              ? line.replaceFirst(':', '<br>')
              : line;
        }).toList();

    /// 添加原始内容
    modifiedLines.addAll(lines);

    if (lines.isNotEmpty) {
      final content = lines.join('\n');

      /// 翻译原始内容
      final translatedText = await _fetchTranslate(content);

      /// 添加翻译内容
      if (translatedText != '' && translatedText != content.trim()) {
        modifiedLines.add('');

        /// 添加缩进
        modifiedLines.addAll(
          translatedText
              .split('\n')
              .map((line) => '${_indentText(lines[0])}${line.trim()}'),
        );
      }
    }
  }

  /// 翻译标题
  Future<void> _translateMarkdownTitle(TextStructure textStructure) async {
    final lines = textStructure.originalText;

    /// 添加原始内容
    modifiedLines.addAll(lines);

    if (lines.isNotEmpty) {
      final content = lines.join('\n');

      final markdownTitleRegex = RegExp(r'^\s*(#{1,6})\s*(.*?)\s*$');
      final markdownTitleMatch = markdownTitleRegex.firstMatch(content);
      if (markdownTitleMatch != null) {
        final titlePrefix = markdownTitleMatch.group(1);
        final titleText = markdownTitleMatch.group(2);
        if (titlePrefix == null || titleText == null) return;

        /// 翻译原始内容
        final translatedText = await _fetchTranslate(titleText);

        /// 添加翻译内容
        if (translatedText != '' && translatedText != titleText.trim()) {
          modifiedLines.add('');

          /// 添加前缀
          modifiedLines.add('$titlePrefix $translatedText');
        }
      }
    }
  }

  /// 翻译列表项
  Future<void> _translateMarkdownListItem(TextStructure textStructure) async {
    final lines = textStructure.originalText;

    /// 添加原始内容
    modifiedLines.addAll(lines);

    if (lines.isNotEmpty) {
      final markdownListItemRegex = RegExp(r'^\s*([*\-+]|\d+\.)\s+(.+)$');
      final markdownListItemMatch = markdownListItemRegex.firstMatch(lines[0]);
      if (markdownListItemMatch != null) {
        final listItemPrefix = markdownListItemMatch.group(1);
        final listItemText = markdownListItemMatch.group(2);
        if (listItemPrefix == null || listItemText == null) return;

        /// 翻译原始内容
        final content =
            '$listItemText\n${lines.where((value) => value != lines[0]).join('\n')}';
        final translatedText = await _fetchTranslate(content);

        /// 添加翻译内容
        if (translatedText != '' && translatedText != content.trim()) {
          modifiedLines.add('');

          /// 添加前缀
          modifiedLines.addAll(
            translatedText
                .split('\n')
                .map((line) => '${' ' * listItemPrefix.length} ${line.trim()}'),
          );
        }
      }
    }
  }

  /// 翻译 Markdown 自定义 aside/admonition 语法（存在类型、标题）
  Future<void> _translateMarkdownCustomAsideTypeTitle(
    TextStructure textStructure,
  ) async {
    final lines = textStructure.originalText;
    if (lines.isNotEmpty) {
      final content = lines[0];

      /// 添加注释原始内容
      modifiedLines.add(
        '${_indentText(content)}<!-- ${content.trimLeft()} -->',
      );

      /// `:::类型 标题`
      final markdownCustomAsideRegex = RegExp(
        r'^\s*(:::)\s*([a-zA-Z0-9-]*)\s*(.*)$',
      );
      if (markdownCustomAsideRegex.hasMatch(content)) {
        final match = markdownCustomAsideRegex.firstMatch(content);
        final delimiter = match!.group(1)!; // 必为 :::
        final type = match.group(2)?.trim() != '' ? match.group(2) : null;
        final title = match.group(3)?.trim() != '' ? match.group(3) : null;

        if (type != null && title != null) {
          /// 翻译原始内容
          final translatedText = await _fetchTranslate(title.trim());

          /// 添加翻译内容
          if (translatedText != '' && translatedText != title.trim()) {
            /// 添加缩进
            modifiedLines.add(
              '${_indentText(content)}$delimiter$type ${translatedText.trim()}',
            );
          }
        }
      }
    }
  }

  /// 翻译 Liquid `{% tab "标题" %}` 语法
  Future<void> _translateLiquidTab(TextStructure textStructure) async {
    final lines = textStructure.originalText;
    if (lines.isNotEmpty) {
      final content = lines[0];

      // 判定 `{% tab "标题" %}`
      if (content.trimLeft().startsWith('{% tab ')) {
        /// 添加注释原始内容
        modifiedLines.add(
          '${_indentText(content)}<!-- ${content.trimLeft()} -->',
        );

        /// `{% tab "标题" %}`
        final liquidTabRegex = RegExp(r'^\s*\{%\s+tab\s+"([^"]+)"\s*%\}$');
        if (liquidTabRegex.hasMatch(content)) {
          final match = liquidTabRegex.firstMatch(content);
          final title = match!.group(1)!;

          if (title.trim() != '') {
            /// 翻译原始内容
            final translatedText = await _fetchTranslate(title.trim());

            /// 添加翻译内容
            if (translatedText != '' && translatedText != title.trim()) {
              /// 添加缩进
              modifiedLines.add(
                '${_indentText(content)}{% tab "${translatedText.trim()}" %}',
              );
              return;
            }
          }
        }
      }
      modifiedLines.addAll(lines);
    }
  }

  /// 缩进
  /// - [content] 获取文本缩进内容
  String _indentText(String content) {
    final regex = RegExp(r'^ *');
    final match = regex.firstMatch(content);
    final indentCount = match?.end ?? 0;
    final indent = ' ' * indentCount;
    return indent;
  }
}

/// 文本结构
class TextStructure {
  const TextStructure({
    required this.type,
    required this.start,
    required this.end,
    required this.originalText,
  });

  /// 文本结构类型
  final TextStructureType type;

  /// 起始行号（从 0 开始）
  final int start;

  /// 结束行号
  final int end;

  /// 原始文本行
  final List<String> originalText;

  TextStructure copyWith({
    TextStructureType? type,
    int? start,
    int? end,
    List<String>? originalText,
    List<String>? plainText,
    String? syntaxPrefix,
    String? syntaxSuffix,
  }) {
    return TextStructure(
      type: type ?? this.type,
      start: start ?? this.start,
      end: end ?? this.end,
      originalText: originalText ?? this.originalText,
    );
  }

  @override
  String toString() =>
      '\nTextStructure(\n'
      '  type: $type, start: $start, end: $end,\n'
      '  originalText: $originalText,\n'
      ')';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextStructure &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          start == other.start &&
          end == other.end &&
          originalText == other.originalText;

  @override
  int get hashCode => Object.hashAll([type, start, end, originalText]);
}
