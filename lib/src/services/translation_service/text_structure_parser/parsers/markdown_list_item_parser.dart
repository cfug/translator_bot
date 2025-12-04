import '../../../../utils.dart';
import '../models/text_structure_model.dart';
import '../../enum.dart';
import '../text_parser.dart';
import 'markdown_code_block_parser.dart';

/// Markdown 列表项 - 多行内容 解析器
/// `* xxx`、`- xxx`、`+ xxx`、`1. xxx`
class MarkdownListItemParser implements TextParser {
  static final regex = RegExp(r'^\s*([*\-+]|\d+\.)\s+(.+)$');

  @override
  int get priority => 5;

  @override
  ParseResult parse(ParseContext context) {
    final lineTrim = context.currentLineTrim;
    final lineNextTrim = context.nextLineTrim;

    if (regex.hasMatch(lineTrim)) {
      /// 列表项开始
      if (context.currentType != TextStructureType.markdownListItem) {
        context.currentType = TextStructureType.markdownListItem;
        context.startLineIndex = context.currentIndex;
      }
    }
    if (context.currentType == TextStructureType.markdownListItem) {
      /// 列表项内容
      context.originalText.add(context.currentLine);

      /// 判定是否结束列表项
      var isListItemEnd = false;
      if (lineNextTrim != null) {
        /// 下一行是否 非当前列表项内容
        final isNextLineNotCurrentText =
            lineNextTrim == '' ||
            lineNextTrim.startsWith(MarkdownCodeBlockParser.delimiter) ||
            regex.hasMatch(lineNextTrim);

        if (isNextLineNotCurrentText) {
          isListItemEnd = true;
        }
      } else {
        isListItemEnd = true;
      }

      /// 结束列表项
      if (isListItemEnd) {
        /// 标记中文
        final isChinese = Utils.isChinese(context.originalText.join());
        final type = isChinese
            ? TextStructureType.chineseMarkdownListItem
            : TextStructureType.markdownListItem;

        /// 添加结构数据
        context.addStructure(
          TextStructure(
            type: type,
            start: context.startLineIndex,
            end: context.currentIndex,
            originalText: context.originalText,
          ),
        );

        context.reset();
      }
      return ParseResult.handled;
    }

    return ParseResult.notHandled;
  }
}
