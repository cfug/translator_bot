import '../../../../utils.dart';
import '../../enum.dart';
import '../models/text_structure_model.dart';
import '../text_parser.dart';

/// Markdown 标题解析器
/// `# xxx`
class MarkdownTitleParser implements TextParser {
  @override
  int get priority => 6;

  static bool hasMatch(String line) =>
      RegExp(r'^\s*#{1,6}\s+.+$').hasMatch(line);

  @override
  ParseResult parse(ParseContext context) {
    if (hasMatch(context.currentLineTrim)) {
      final isChinese = Utils.isChinese(context.currentLine);
      context.addStructure(
        TextStructure(
          type: isChinese
              ? TextStructureType.chineseMarkdownTitle
              : TextStructureType.markdownTitle,
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
