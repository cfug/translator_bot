import '../../../../utils.dart';
import '../models/text_structure_model.dart';
import '../../enum.dart';
import '../text_parser.dart';

/// 单行 Markdown 自定义 Aside 语法 解析器
/// `:::类型 标题`
class MarkdownCustomAsideTypeParser implements TextParser {
  @override
  int get priority => 9;

  static RegExp regex = RegExp(r'^\s*(:::)\s*([a-zA-Z0-9-]*)\s*(.*)$');
  static bool hasMatch(String line) => regex.hasMatch(line);

  @override
  ParseResult parse(ParseContext context) {
    final lineTrim = context.currentLineTrim;
    if (hasMatch(lineTrim)) {
      final match = regex.firstMatch(lineTrim);
      // final delimiter = match!.group(1)!; // 必为 :::
      final type = match?.group(2)?.trim() != '' ? match?.group(2) : null;
      final title = match?.group(3)?.trim() != '' ? match?.group(3) : null;

      var markdownCustomAsideType = TextStructureType.markdownCustomAsideEnd;
      if (type != null && title != null) {
        /// 标记中文
        final isChinese = Utils.isChinese(context.currentLine);
        markdownCustomAsideType = isChinese
            ? TextStructureType.chineseMarkdownCustomAsideTypeTitle
            : TextStructureType.markdownCustomAsideTypeTitle;
      } else if (type != null) {
        markdownCustomAsideType = TextStructureType.markdownCustomAsideType;
      }

      context.addStructure(
        TextStructure(
          type: markdownCustomAsideType,
          start: context.currentIndex,
          end: context.currentIndex,
          originalText: [context.currentLine],
        ),
      );

      return ParseResult.handled;
    }
    return ParseResult.notHandled;
  }
}
