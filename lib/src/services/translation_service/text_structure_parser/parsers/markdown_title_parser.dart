import '../../../../utils.dart';
import '../../enum.dart';
import '../models/text_structure_model.dart';
import '../text_parser.dart';

/// Markdown 标题解析器
/// `# xxx`
class MarkdownTitleParser implements TextParser {
  static final regex = RegExp(r'^\s*#{1,6}\s+.+$');

  @override
  int get priority => 6;

  @override
  ParseResult parse(ParseContext context) {
    if (regex.hasMatch(context.currentLineTrim)) {
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
