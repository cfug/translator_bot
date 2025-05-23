import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:uuid/uuid.dart';

import 'reformat_text.dart';

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
}

class TranslateTextChunk {
  /// 文本分块翻译处理
  TranslateTextChunk(this.chat, this.text);

  /// 模型会话
  final ChatSession chat;

  /// 需要处理的原始内容
  final String text;

  /// 翻译 ID 占位修改后的行内容
  final List<String> modifiedLines = [];

  /// 翻译 ID 占位块的数据
  final List<TranslationChunk> translationChunkList = [];

  /// 在文档顶部的翻译说明
  String get translationNote =>
      '\n:::note\n'
      '本篇文档由 AI 翻译。\n'
      ':::';

  Future<String> run() async {
    final content = ReformatText(text).all();
    final textStructureList = _parseTextStructure(content);
    _chunkTextStructure(textStructureList);
    final translatedText = await _translateChunkTextStructure() ?? text;
    return translatedText;
  }

  /// 处理文本结构数据（按行识别）
  ///
  /// TODO: 用 AST tree 来实现
  ///
  /// - [content] 需要结构处理的内容
  List<TextStructure> _parseTextStructure(String content) {
    /// 内容结构的数据（可以完全还原至原始内容）
    final textStructureList = <TextStructure>[];

    /// 当前文本结构类型
    var textStructureType = TextStructureType.none;

    /// 当前起始行
    var startLineIndex = 0;

    /// 当前结束行
    var endLineIndex = 0;

    /// 原始文本行
    var originalText = <String>[];

    /// 按行处理
    final lines = content.split('\n');
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

      /* BEGIN Markdown 表格 */
      final markdownTableRegex = RegExp(r'^\s*(\S.*?\|.*\S)\s*$');
      if (markdownTableRegex.hasMatch(lineTrim)) {
        if (textStructureType != TextStructureType.markdownTable) {
          /// Markdown 表格 - 开始
          textStructureType = TextStructureType.markdownTable;
          startLineIndex = i;
          originalText.add(line);
          continue;
        } else {
          if (lineNextTrim == null ||
              !markdownTableRegex.hasMatch(lineNextTrim)) {
            /// Markdown 表格 - 结束
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
        }
      }

      /// Markdown 表格 - 内容
      if (textStructureType == TextStructureType.markdownTable) {
        originalText.add(line);
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
              markdownTableRegex.hasMatch(lineNextTrim) ||
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

  /// 分块文本结构（翻译 ID 占位）
  /// - [textStructureList] 整篇文本结构
  void _chunkTextStructure(List<TextStructure> textStructureList) {
    for (var i = 0; i < textStructureList.length; i++) {
      final textStructure = textStructureList[i];
      final textStructureType = textStructure.type;
      final textStructureNext =
          i == textStructureList.length - 1 ? null : textStructureList[i + 1];

      switch (textStructureType) {
        case TextStructureType.topMetadata:
          _chunkTopMetadata(textStructure);
          modifiedLines.add(translationNote);
          if (textStructureNext != null &&
              textStructureNext.type != TextStructureType.blankLine) {
            modifiedLines.add('');
          }
        case TextStructureType.paragraph:
          _chunkMarkdownParagraph(textStructure);
          if (textStructureNext != null &&
              textStructureNext.type != TextStructureType.blankLine) {
            modifiedLines.add('');
          }
        case TextStructureType.markdownTitle:
          _chunkMarkdownTitle(textStructure);
          if (textStructureNext != null &&
              textStructureNext.type != TextStructureType.blankLine) {
            modifiedLines.add('');
          }
        case TextStructureType.markdownListItem:
          _chunkMarkdownListItem(textStructure);
          if (textStructureNext != null &&
              textStructureNext.type != TextStructureType.blankLine) {
            modifiedLines.add('');
          }
        case TextStructureType.markdownTable:
          _chunkMarkdownTable(textStructure);
          if (textStructureNext != null &&
              textStructureNext.type != TextStructureType.blankLine) {
            modifiedLines.add('');
          }
        case TextStructureType.markdownCustomAsideTypeTitle:
          _chunkMarkdownCustomAsideTypeTitle(textStructure);
          if (textStructureNext != null &&
              textStructureNext.type != TextStructureType.blankLine) {
            modifiedLines.add('');
          }
        case TextStructureType.liquid1:
          _chunkLiquidTab(textStructure);
        case _:
          modifiedLines.addAll(textStructure.originalText);
      }
    }
  }

  /// 分块顶部元数据（翻译 ID 占位）
  void _chunkTopMetadata(TextStructure textStructure) {
    final lines = textStructure.originalText;

    /// 当前正在识别的元数据属性名称
    String? currentMetadataLineName;

    /// 当前正在识别的元数据属性内容
    var currentMetadataLineValue = <String>[];

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
      final metadataName = metadataLine[0];

      /// 当前行存在属性
      if (metadataLine.length >= 2) {
        final metadataValue = metadataLine[1].trim();

        /// 存在父属性
        if (metadataValue == '') {
          modifiedLines.add(line);
          continue;
        }

        /// 处理指定属性
        if ([
          'title',
          'short-title',
          'description',
        ].any((value) => metadataName.trim() == value)) {
          /// 注释行
          modifiedLines.add('# $line');

          /// 标注当前行
          currentMetadataLineName = metadataName;
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
        } else {
          modifiedLines.add(line);
        }
      }

      /// 下一行是否存在属性/已经结束，如果存在就代表需要翻译处理当前属性内容
      final metadataLineNext = lineNext?.split(':') ?? [];
      if ((metadataLineNext.length >= 2 || lineNext?.trim() == '---') &&
          currentMetadataLineName != null) {
        /// 翻译块 ID
        final translationChunkId = _translationChunkId();

        /// 当前已存在属性，进行翻译块 ID 占位
        translationChunkList.add(
          TranslationChunk(
            id: translationChunkId,
            indentCount: 0,
            text: currentMetadataLineValue.join(''),
          ),
        );
        modifiedLines.add('$currentMetadataLineName: $translationChunkId');

        /// 清理标注
        currentMetadataLineName = null;
        currentMetadataLineValue = [];
      }
    }
  }

  /// 分块段落（翻译 ID 占位）
  void _chunkMarkdownParagraph(TextStructure textStructure) {
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

      /// 翻译块 ID
      final translationChunkId = _translationChunkId();

      /// 添加翻译块 ID 占位
      translationChunkList.add(
        TranslationChunk(
          id: translationChunkId,
          indentCount: _indentCount(lines[0]),
          text: content,
        ),
      );
      modifiedLines.add('');
      modifiedLines.add(translationChunkId);
    }
  }

  /// 分块标题（翻译 ID 占位）
  void _chunkMarkdownTitle(TextStructure textStructure) {
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

        /// 翻译块 ID
        final translationChunkId = _translationChunkId();

        /// 添加翻译块 ID 占位
        translationChunkList.add(
          TranslationChunk(
            id: translationChunkId,
            indentCount: 0,
            text: titleText,
          ),
        );
        modifiedLines.add('');
        modifiedLines.add('$titlePrefix $translationChunkId');
      }
    }
  }

  /// 分块列表项（翻译 ID 占位）
  void _chunkMarkdownListItem(TextStructure textStructure) {
    final lines = textStructure.originalText;

    /// 添加原始内容
    modifiedLines.addAll(lines);

    if (lines.isNotEmpty) {
      final markdownListItemRegex = RegExp(r'^\s*([*\-+]|\d+\.)\s+(.+)$');
      final markdownListItemMatch = markdownListItemRegex.firstMatch(lines[0]);
      if (markdownListItemMatch != null) {
        final listItemPrefix = markdownListItemMatch.group(1);
        final listItemTextFirstLine = markdownListItemMatch.group(2);
        if (listItemPrefix == null || listItemTextFirstLine == null) return;
        final indentCount = _indentCount(lines[0]) + listItemPrefix.length + 1;

        /// 翻译原始内容
        final content =
            '$listItemTextFirstLine\n${lines.where((value) => value != lines[0]).join('\n')}';

        /// 翻译块 ID
        final translationChunkId = _translationChunkId();

        /// 添加翻译块 ID 占位
        translationChunkList.add(
          TranslationChunk(
            id: translationChunkId,
            indentCount: indentCount,
            text: content,
          ),
        );
        modifiedLines.add('');
        modifiedLines.add(translationChunkId);
      }
    }
  }

  /// 分块表格（翻译 ID 占位）
  void _chunkMarkdownTable(TextStructure textStructure) {
    final lines = textStructure.originalText;

    /// 至少 3 行（表头 分割 主内容）
    if (lines.length >= 3) {
      final tableHeader = lines[0];
      final tableSeparator = lines[1];
      final indentText = ' ' * _indentCount(tableHeader);

      /// 处理表头
      final modifiedTableHeader = tableHeader
          .split('|')
          .map((cell) {
            final cellTrim = cell.trim();
            if (cellTrim != '') {
              /// 翻译块 ID
              final translationChunkId = _translationChunkId();

              /// 添加翻译块 ID 占位
              translationChunkList.add(
                TranslationChunk(
                  id: translationChunkId,
                  indentCount: 0,
                  text: cellTrim,
                ),
              );

              return '<t>$cellTrim</t><t>$translationChunkId</t>';
            } else {
              return cell;
            }
          })
          .join('|');
      modifiedLines.add('$indentText$modifiedTableHeader');
      modifiedLines.add('$indentText$tableSeparator');

      /// 处理表主体内容
      for (var i = 2; i < lines.length; i++) {
        final tableData = lines[i];

        /// 添加原始行
        modifiedLines.add(tableData);

        /// 添加翻译占位 ID 行
        final modifiedTableData = tableData
            .split('|')
            .map((cell) {
              final cellTrim = cell.trim();

              if (cellTrim != '') {
                /// 翻译块 ID
                final translationChunkId = _translationChunkId();

                /// 添加翻译块 ID 占位
                translationChunkList.add(
                  TranslationChunk(
                    id: translationChunkId,
                    indentCount: 0,
                    text: cellTrim,
                  ),
                );

                return translationChunkId;
              } else {
                return cell;
              }
            })
            .join('|');
        modifiedLines.add('$indentText$modifiedTableData');
      }
    }
  }

  /// 分块 Markdown 自定义 aside/admonition 语法（存在类型、标题）
  void _chunkMarkdownCustomAsideTypeTitle(TextStructure textStructure) {
    final lines = textStructure.originalText;
    if (lines.isNotEmpty) {
      final content = lines[0];

      /// 添加注释原始内容
      modifiedLines.add(
        '${" " * _indentCount(content)}<!-- ${content.trimLeft()} -->',
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
          /// 翻译块 ID
          final translationChunkId = _translationChunkId();

          /// 添加翻译块 ID 占位
          translationChunkList.add(
            TranslationChunk(
              id: translationChunkId,
              indentCount: 0,
              text: title,
            ),
          );
          modifiedLines.add(
            '${" " * _indentCount(content)}$delimiter$type $translationChunkId',
          );
        }
      }
    }
  }

  /// 分块 Liquid `{% tab "标题" %}` 语法
  void _chunkLiquidTab(TextStructure textStructure) {
    final lines = textStructure.originalText;
    if (lines.isNotEmpty) {
      final content = lines[0];

      // 判定 `{% tab "标题" %}`
      if (content.trimLeft().startsWith('{% tab ')) {
        /// 添加注释原始内容
        modifiedLines.add(
          '${" " * _indentCount(content)}<!-- ${content.trimLeft()} -->',
        );

        /// `{% tab "标题" %}`
        final liquidTabRegex = RegExp(r'^\s*\{%\s+tab\s+"([^"]+)"\s*%\}$');
        if (liquidTabRegex.hasMatch(content)) {
          final match = liquidTabRegex.firstMatch(content);
          final title = match!.group(1)!;

          if (title.trim() != '') {
            /// 翻译块 ID
            final translationChunkId = _translationChunkId();

            /// 添加翻译块 ID 占位
            translationChunkList.add(
              TranslationChunk(
                id: translationChunkId,
                indentCount: 0,
                text: title.trim(),
              ),
            );
            modifiedLines.add(
              '${" " * _indentCount(content)}{% tab "$translationChunkId" %}',
            );
            return;
          }
        }
      }
      modifiedLines.addAll(lines);
    }
  }

  /// 翻译分块的文本结构
  ///
  /// @return 翻译完成的内容，`null`: 翻译为空
  Future<String?> _translateChunkTextStructure() async {
    /// 最大输入计数（防止输出超出限制）
    const maxInputCount = 10 * 1024;
    final inputChunkTextList = <String>[];

    /// 处理成 AI 需要输入的格式内容
    var chunkText = '';
    for (var i = 0; i < translationChunkList.length; i++) {
      final translationChunk = translationChunkList[i];
      chunkText +=
          '<INPUT>\n'
          'id: ${translationChunk.id}\n'
          'indentCount: ${translationChunk.indentCount}\n'
          'text: ${translationChunk.text.split('\n').join('\\n')}\n'
          '</INPUT>\n'
          '\n';

      /// 分段输入
      if (chunkText.length >= maxInputCount ||
          i == translationChunkList.length - 1) {
        if (chunkText != '') {
          inputChunkTextList.add(chunkText);

          /// 清理
          chunkText = '';
        }
      }
    }

    if (inputChunkTextList.isNotEmpty) {
      /// 已翻译完成的分块数据
      final translatedChunkList = <TranslationChunk>[];

      print('🚀 总共需要翻译的数据：${inputChunkTextList.length} 批');

      /// 开始翻译
      for (var i = 0; i < inputChunkTextList.length; i++) {
        print('📄 开始翻译第 ${i + 1} 批数据');
        final inputChunkText = inputChunkTextList[i];

        /// TODO: 限制最多请求 10 次就暂停 1 分钟
        final translatedResponse = await chat.sendMessage(
          Content.text(inputChunkText),
        );
        final translatedText = translatedResponse.text?.trim() ?? '';
        if (translatedText != '') {
          try {
            final List<dynamic> translatedJsonList = jsonDecode(translatedText);
            for (final translatedJson in translatedJsonList) {
              translatedChunkList.add(
                TranslationChunk.fromJson(translatedJson),
              );
            }
          } catch (e) {
            throw GenerativeAIException(
              'AI 响应输出的 json 格式处理错误\n'
              '$e\n',
            );
          }
        }
        print('✅ 完成翻译第 ${i + 1} 批数据');
      }

      /// 将翻译替换至原文
      var modifiedText = modifiedLines.join('\n');
      for (final translatedChunk in translatedChunkList) {
        modifiedText = modifiedText.replaceAll(
          translatedChunk.id,
          translatedChunk.text
              .trim()
              .split('\n')
              .map(
                (line) => '${" " * translatedChunk.indentCount}${line.trim()}',
              )
              .join('\n'),
        );
      }
      return modifiedText;
    }
    return null;
  }

  /// 生成翻译块 ID
  String _translationChunkId() => '#{TranslationChunkId-${const Uuid().v7()}}#';

  /// 缩进计数
  /// - [content] 获取文本缩进内容
  int _indentCount(String content) {
    final regex = RegExp(r'^ *');
    final match = regex.firstMatch(content);
    final indentCount = match?.end ?? 0;
    return indentCount;
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

/// 翻译块数据
class TranslationChunk {
  const TranslationChunk({
    required this.id,
    required this.indentCount,
    required this.text,
  });

  factory TranslationChunk.fromJson(Map json) {
    return TranslationChunk(
      id: json['id'],
      indentCount: json['indentCount'],
      text: json['text'],
    );
  }

  /// 翻译块 ID
  ///
  /// 用于替换原文翻译占位的 ID
  final String id;

  /// 缩进计数
  final int indentCount;

  /// 内容（需要翻译、已翻译）
  final String text;

  Map<String, dynamic> toJson() {
    return {'id': id, 'indentCount': indentCount, 'text': text};
  }

  TranslationChunk copyWith({String? id, String? text, int? indentCount}) {
    return TranslationChunk(
      id: id ?? this.id,
      indentCount: indentCount ?? this.indentCount,
      text: text ?? this.text,
    );
  }

  @override
  String toString() =>
      '\nTranslationChunk(\n'
      '  id: $id,\n'
      '  indentCount: $indentCount,\n'
      '  text: $text,\n'
      ')';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranslationChunk &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          indentCount == other.indentCount &&
          text == other.text;

  @override
  int get hashCode => Object.hashAll([id, indentCount, text]);
}
