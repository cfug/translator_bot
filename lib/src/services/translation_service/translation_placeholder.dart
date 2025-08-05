import 'package:uuid/uuid.dart';

import 'models/text_structure_model.dart';
import 'models/translation_chunk_model.dart';
import 'enum.dart';

/// 译文占位符处理
class TranslationPlaceholder {
  /// 译文占位符处理
  TranslationPlaceholder(this.uuid);

  final Uuid uuid;

  /// 译文 ID 占位修改后的原始行内容
  final List<String> placeholderOriginalLines = [];

  /// 译文 ID 占位块的数据
  final List<TranslationChunk> translationPlaceholderData = [];

  /// 生成译文块 ID
  String _translationChunkId() => '#{TranslationChunkId-${uuid.v7()}}#';

  /// 在文档顶部的翻译说明
  String get translationNote =>
      '\n:::note\n\n'
      '本篇文档由 AI 翻译。\n\n'
      ':::';

  /// 译文 ID 占位处理
  ///
  /// 在 [textStructureList] 整篇文本结构中对应位置插入译文 ID 的占位，
  /// 便于之后翻译替换处理。
  ///
  /// - [textStructureList] 整篇文本结构
  void execute(List<TextStructure> textStructureList) {
    for (var i = 0; i < textStructureList.length; i++) {
      final textStructure = textStructureList[i];
      final textStructureType = textStructure.type;

      switch (textStructureType) {
        case TextStructureType.topMetadata:
          _chunkTopMetadata(i, textStructure, textStructureList);
          placeholderOriginalLines.add(translationNote);
        case TextStructureType.paragraph:
          _chunkMarkdownParagraph(i, textStructure, textStructureList);
        case TextStructureType.markdownTitle:
          _chunkMarkdownTitle(i, textStructure, textStructureList);
        case TextStructureType.markdownListItem:
          _chunkMarkdownListItem(i, textStructure, textStructureList);
        case TextStructureType.markdownTable:
          _chunkMarkdownTable(i, textStructure, textStructureList);
        case TextStructureType.markdownCustomAsideTypeTitle:
          _chunkMarkdownCustomAsideTypeTitle(
            i,
            textStructure,
            textStructureList,
          );
        case TextStructureType.liquid1:
          _chunkLiquidTab(textStructure);
        case _:
          placeholderOriginalLines.addAll(textStructure.originalText);
      }
    }
  }

  /// 分块顶部元数据（译文 ID 占位）
  /// - [index] 当前数据索引
  /// - [textStructure] 当前数据
  /// - [textStructureList] 所有数据
  void _chunkTopMetadata(
    int index,
    TextStructure textStructure,
    List<TextStructure> textStructureList,
  ) {
    final lines = textStructure.originalText;
    final textStructureNext = index == textStructureList.length - 1
        ? null
        : textStructureList[index + 1];

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
        placeholderOriginalLines.add(line);
        continue;
      }

      /// 顶部元数据 - 结束
      if (i != 0 && line.trim() == '---') {
        placeholderOriginalLines.add(line);
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
          placeholderOriginalLines.add(line);
          continue;
        }

        /// 处理指定属性
        if ([
          'title',
          'short-title',
          'description',
        ].any((value) => metadataName.trim() == value)) {
          /// 注释行
          placeholderOriginalLines.add('# $line');

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
          placeholderOriginalLines.add(line);
        }
      } else {
        /// 当前行不存在属性，表明为当前属性的内容
        if (currentMetadataLineName != null) {
          /// 注释行
          placeholderOriginalLines.add('# $line');
          currentMetadataLineValue.add(line.trim());
        } else {
          placeholderOriginalLines.add(line);
        }
      }

      /// 下一行是否存在属性/已经结束，如果存在就代表需要翻译处理当前属性内容
      final metadataLineNext = lineNext?.split(':') ?? [];
      if ((metadataLineNext.length >= 2 || lineNext?.trim() == '---') &&
          currentMetadataLineName != null) {
        /// 翻译块 ID
        final translationChunkId = _translationChunkId();

        /// 当前已存在属性，进行翻译块 ID 占位
        translationPlaceholderData.add(
          TranslationChunk(
            id: translationChunkId,
            indentCount: 0,
            text: currentMetadataLineValue.join(''),
          ),
        );
        placeholderOriginalLines.add(
          '$currentMetadataLineName: $translationChunkId',
        );

        /// 清理标注
        currentMetadataLineName = null;
        currentMetadataLineValue = [];
      }
    }

    if (textStructureNext != null &&
        textStructureNext.type != TextStructureType.blankLine) {
      placeholderOriginalLines.add('');
    }
  }

  /// 分块段落（译文 ID 占位）
  /// - [index] 当前数据索引
  /// - [textStructure] 当前数据
  /// - [textStructureList] 所有数据
  void _chunkMarkdownParagraph(
    int index,
    TextStructure textStructure,
    List<TextStructure> textStructureList,
  ) {
    var lines = textStructure.originalText;
    final textStructureNext = index == textStructureList.length - 1
        ? null
        : textStructureList[index + 1];
    final textStructureNext2 = index >= textStructureList.length - 2
        ? null
        : textStructureList[index + 2];
    final textStructureNext2IsChinese =
        textStructureNext2?.type.isChinese ?? false;

    /// 处理 `:` 开头的情况
    lines = lines.map((line) {
      return line.trimLeft().startsWith(':')
          ? line.replaceFirst(':', '<br>')
          : line;
    }).toList();

    /// 添加原始内容
    placeholderOriginalLines.addAll(lines);

    if (lines.isNotEmpty && !textStructureNext2IsChinese) {
      final content = lines.join('\n');

      /// 翻译块 ID
      final translationChunkId = _translationChunkId();

      /// 添加翻译块 ID 占位
      translationPlaceholderData.add(
        TranslationChunk(
          id: translationChunkId,
          indentCount: _indentCount(lines[0]),
          text: content,
        ),
      );
      placeholderOriginalLines.add('');
      placeholderOriginalLines.add(translationChunkId);

      if (textStructureNext != null &&
          textStructureNext.type != TextStructureType.blankLine) {
        placeholderOriginalLines.add('');
      }
    }
  }

  /// 分块标题（译文 ID 占位）
  /// - [index] 当前数据索引
  /// - [textStructure] 当前数据
  /// - [textStructureList] 所有数据
  void _chunkMarkdownTitle(
    int index,
    TextStructure textStructure,
    List<TextStructure> textStructureList,
  ) {
    final lines = textStructure.originalText;
    final textStructureNext = index == textStructureList.length - 1
        ? null
        : textStructureList[index + 1];
    final textStructureNext2 = index >= textStructureList.length - 2
        ? null
        : textStructureList[index + 2];

    /// 添加原始内容
    placeholderOriginalLines.addAll(lines);

    if (lines.isEmpty) return;

    /// 处理需要翻译的内容
    final content = lines.join('\n');

    /// 匹配标题前缀
    final markdownTitleRegex = RegExp(r'^\s*(#{1,6})\s*(.*?)\s*$');

    /// 匹配当前行标题
    final markdownTitleMatch = markdownTitleRegex.firstMatch(content);
    if (markdownTitleMatch == null) return;
    final titlePrefix = markdownTitleMatch.group(1);
    final titleText = markdownTitleMatch.group(2);
    if (titlePrefix == null || titleText == null) return;

    /// 下两行标题是否存在中文
    final textStructureNext2IsChinese =
        textStructureNext2?.type.isChinese ?? false;

    /// 下两行标题前缀
    String? titlePrefixNext2;
    if (textStructureNext2 != null) {
      final contentNext2 = textStructureNext2.originalText.join('\n');
      final markdownTitleMatch = markdownTitleRegex.firstMatch(contentNext2);
      if (markdownTitleMatch != null) {
        titlePrefixNext2 = markdownTitleMatch.group(1);
      }
    }

    /// 下两行标题前缀可匹配并且为中文的情况，可匹配则跳过翻译
    if (titlePrefix == titlePrefixNext2 && textStructureNext2IsChinese) {
      return;
    }

    /// 翻译块 ID
    final translationChunkId = _translationChunkId();

    /// 添加翻译块 ID 占位
    translationPlaceholderData.add(
      TranslationChunk(id: translationChunkId, indentCount: 0, text: titleText),
    );
    placeholderOriginalLines.add('');
    placeholderOriginalLines.add('$titlePrefix $translationChunkId');

    if (textStructureNext != null &&
        textStructureNext.type != TextStructureType.blankLine) {
      placeholderOriginalLines.add('');
    }
  }

  /// 分块列表项（译文 ID 占位）
  /// - [index] 当前数据索引
  /// - [textStructure] 当前数据
  /// - [textStructureList] 所有数据
  void _chunkMarkdownListItem(
    int index,
    TextStructure textStructure,
    List<TextStructure> textStructureList,
  ) {
    final lines = textStructure.originalText;
    final textStructureNext = index == textStructureList.length - 1
        ? null
        : textStructureList[index + 1];
    final textStructureNext2 = index >= textStructureList.length - 2
        ? null
        : textStructureList[index + 2];
    final textStructureNext2IsChinese =
        textStructureNext2?.type.isChinese ?? false;

    /// 添加原始内容
    placeholderOriginalLines.addAll(lines);

    if (lines.isNotEmpty && !textStructureNext2IsChinese) {
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
        translationPlaceholderData.add(
          TranslationChunk(
            id: translationChunkId,
            indentCount: indentCount,
            text: content,
          ),
        );
        placeholderOriginalLines.add('');
        placeholderOriginalLines.add(translationChunkId);

        if (textStructureNext != null &&
            textStructureNext.type != TextStructureType.blankLine) {
          placeholderOriginalLines.add('');
        }
      }
    }
  }

  /// 分块表格（译文 ID 占位）
  /// - [index] 当前数据索引
  /// - [textStructure] 当前数据
  /// - [textStructureList] 所有数据
  void _chunkMarkdownTable(
    int index,
    TextStructure textStructure,
    List<TextStructure> textStructureList,
  ) {
    final lines = textStructure.originalText;
    final textStructureNext = index == textStructureList.length - 1
        ? null
        : textStructureList[index + 1];

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
              translationPlaceholderData.add(
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
      placeholderOriginalLines.add('$indentText$modifiedTableHeader');
      placeholderOriginalLines.add('$indentText$tableSeparator');

      /// 处理表主体内容
      for (var i = 2; i < lines.length; i++) {
        final tableData = lines[i];

        /// 添加原始行
        placeholderOriginalLines.add(tableData);

        /// 添加翻译占位 ID 行
        final modifiedTableData = tableData
            .split('|')
            .map((cell) {
              final cellTrim = cell.trim();

              if (cellTrim != '') {
                /// 翻译块 ID
                final translationChunkId = _translationChunkId();

                /// 添加翻译块 ID 占位
                translationPlaceholderData.add(
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
        placeholderOriginalLines.add('$indentText$modifiedTableData');
      }
    }

    if (textStructureNext != null &&
        textStructureNext.type != TextStructureType.blankLine) {
      placeholderOriginalLines.add('');
    }
  }

  /// 分块 Markdown 自定义 aside/admonition 语法（存在类型、标题）（译文 ID 占位）
  /// - [index] 当前数据索引
  /// - [textStructure] 当前数据
  /// - [textStructureList] 所有数据
  void _chunkMarkdownCustomAsideTypeTitle(
    int index,
    TextStructure textStructure,
    List<TextStructure> textStructureList,
  ) {
    final lines = textStructure.originalText;
    final textStructureNext = index == textStructureList.length - 1
        ? null
        : textStructureList[index + 1];

    if (lines.isNotEmpty) {
      final content = lines[0];

      /// 添加注释原始内容
      placeholderOriginalLines.add(
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
          translationPlaceholderData.add(
            TranslationChunk(
              id: translationChunkId,
              indentCount: 0,
              text: title,
            ),
          );
          placeholderOriginalLines.add(
            '${" " * _indentCount(content)}$delimiter$type $translationChunkId',
          );

          if (textStructureNext != null &&
              textStructureNext.type != TextStructureType.blankLine) {
            placeholderOriginalLines.add('');
          }
        }
      }
    }
  }

  /// 分块 Liquid `{% tab "标题" %}` 语法（译文 ID 占位）
  /// - [textStructure] 当前数据
  void _chunkLiquidTab(TextStructure textStructure) {
    final lines = textStructure.originalText;
    if (lines.isNotEmpty) {
      final content = lines[0];

      // 判定 `{% tab "标题" %}`
      if (content.trimLeft().startsWith('{% tab ')) {
        /// 添加注释原始内容
        placeholderOriginalLines.add(
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
            translationPlaceholderData.add(
              TranslationChunk(
                id: translationChunkId,
                indentCount: 0,
                text: title.trim(),
              ),
            );
            placeholderOriginalLines.add(
              '${" " * _indentCount(content)}{% tab "$translationChunkId" %}',
            );
            return;
          }
        }
      }
      placeholderOriginalLines.addAll(lines);
    }
  }

  /// 缩进计数
  /// - [content] 获取文本缩进内容
  int _indentCount(String content) {
    final regex = RegExp(r'^ *');
    final match = regex.firstMatch(content);
    final indentCount = match?.end ?? 0;
    return indentCount;
  }
}
