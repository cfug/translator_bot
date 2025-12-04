import '../../../../utils.dart';
import '../models/text_structure_model.dart';
import '../../enum.dart';
import '../text_parser.dart';

/// Markdown 表格 解析器
class MarkdownTableParser implements TextParser {
  static final regex = RegExp(r'^\s*(\S.*?\|.*\S)\s*$');

  @override
  int get priority => 15;

  @override
  ParseResult parse(ParseContext context) {
    final lineTrim = context.currentLineTrim;
    final lineNextTrim = context.nextLineTrim;

    if (regex.hasMatch(lineTrim)) {
      if (context.currentType != TextStructureType.markdownTable) {
        /// Markdown 表格 - 开始
        context.currentType = TextStructureType.markdownTable;
        context.startLineIndex = context.currentIndex;
        context.originalText.add(context.currentLine);
        return ParseResult.handled;
      } else {
        if (lineNextTrim == null || !regex.hasMatch(lineNextTrim)) {
          /// Markdown 表格 - 结束
          context.originalText.add(context.currentLine);

          /// 标记中文
          final isChinese = Utils.isChinese(context.originalText.join());
          final textStructureType = isChinese
              ? TextStructureType.chineseMarkdownTable
              : TextStructureType.markdownTable;

          /// 添加结构数据
          context.addStructure(
            TextStructure(
              type: textStructureType,
              start: context.startLineIndex,
              end: context.currentIndex,
              originalText: context.originalText,
            ),
          );

          context.reset();
          return ParseResult.handled;
        }
      }
    }

    /// Markdown 表格 - 内容
    if (context.currentType == TextStructureType.markdownTable) {
      context.originalText.add(context.currentLine);
      return ParseResult.handled;
    }
    return ParseResult.notHandled;
  }
}
