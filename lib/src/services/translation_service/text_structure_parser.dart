import '../../utils.dart';
import 'models/text_structure_model.dart';
import 'enum.dart';

/// 文本结构解析器
abstract final class TextStructureParser {
  /// 解析文本结构数据（按行识别）
  ///
  /// TODO: 用 AST tree 来实现，拆分识别特征，避免写在一块
  ///
  /// - [content] 需要结构处理的内容
  static List<TextStructure> parse(String content) {
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

        /// 标记中文
        final isChinese = Utils.isChinese(originalText.join());
        textStructureType = isChinese
            ? TextStructureType.chineseTopMetadata
            : textStructureType;

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

          /// 标记中文
          final isChinese = Utils.isChinese(originalText.join());
          textStructureType = isChinese
              ? TextStructureType.chineseMarkdownListItem
              : textStructureType;

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
        /// 标记中文
        final isChinese = Utils.isChinese(line);
        textStructureList.add(
          TextStructure(
            type: isChinese
                ? TextStructureType.chineseMarkdownTitle
                : TextStructureType.markdownTitle,
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

        var markdownCustomAsideType = TextStructureType.markdownCustomAsideEnd;
        if (type != null && title != null) {
          /// 标记中文
          final isChinese = Utils.isChinese(line);
          markdownCustomAsideType = isChinese
              ? TextStructureType.chineseMarkdownCustomAsideTypeTitle
              : TextStructureType.markdownCustomAsideTypeTitle;
        } else if (type != null) {
          markdownCustomAsideType = TextStructureType.markdownCustomAsideType;
        }

        textStructureList.add(
          TextStructure(
            type: markdownCustomAsideType,
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
        /// 标记中文
        final isChinese = Utils.isChinese(line);
        textStructureList.add(
          TextStructure(
            type: isChinese
                ? TextStructureType.chinsesLiquid1
                : TextStructureType.liquid1,
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
      if (htmlTagRegex.hasMatch(lineTrim) && !lineTrim.startsWith('<br')) {
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

      /* BEGIN HTML 注释 `<!-- xx -->` */
      final htmlCommentBeginRegex = RegExp(r'^\s*<!--');
      final htmlCommentEndRegex = RegExp(r'-->');

      /// HTML 注释 - 开始
      if (htmlCommentBeginRegex.hasMatch(lineTrim) &&
          textStructureType != TextStructureType.htmlComment) {
        textStructureType = TextStructureType.htmlComment;
        startLineIndex = i;
        originalText.add(line);

        /// HTML 注释 - 单行结束
        if (htmlCommentEndRegex.hasMatch(lineTrim)) {
          /// 添加结构数据
          textStructureList.add(
            TextStructure(
              type: textStructureType,
              start: startLineIndex,
              end: startLineIndex,
              originalText: originalText,
            ),
          );

          /// 清理
          textStructureType = TextStructureType.none;
          originalText = [];
        }
        continue;
      }

      /// HTML 注释 - 多行结束
      if (htmlCommentEndRegex.hasMatch(lineTrim) &&
          textStructureType == TextStructureType.htmlComment) {
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

      /// HTML 注释 - 多行内容
      if (textStructureType == TextStructureType.htmlComment) {
        originalText.add(line);
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

            /// 标记中文
            final isChinese = Utils.isChinese(originalText.join());
            textStructureType = isChinese
                ? TextStructureType.chineseMarkdownTable
                : textStructureType;

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

        /// 下一行是否可判定为上方的其他类型
        final isNextLineNotParagraph =
            lineNextTrim == null ||
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
            (htmlTagRegex.hasMatch(lineNextTrim) &&
                !lineNextTrim.startsWith('<br')) ||
            htmlCommentBeginRegex.hasMatch(lineNextTrim);

        if (isNextLineNotParagraph) {
          isParagraphEnd = true;
        }

        /// 结束段落
        if (isParagraphEnd) {
          endLineIndex = i;

          /// 标记中文
          final isChinese = Utils.isChinese(originalText.join());
          textStructureType = isChinese
              ? TextStructureType.chineseParagraph
              : textStructureType;

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
}
