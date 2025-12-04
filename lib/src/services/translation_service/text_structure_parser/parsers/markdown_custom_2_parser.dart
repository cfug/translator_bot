import '../models/text_structure_model.dart';
import '../../enum.dart';
import '../text_parser.dart';

/// 单行 Markdown 自定义语法2 `<?xxx` 解析器
/// `<?xxx`
class MarkdownCustom2Parser implements TextParser {
  static final regex = RegExp(r'^\s*\<\?');

  @override
  int get priority => 11;

  @override
  ParseResult parse(ParseContext context) {
    final lineTrim = context.currentLineTrim;
    if (regex.hasMatch(lineTrim)) {
      context.addStructure(
        TextStructure(
          type: TextStructureType.markdownCustom2,
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
