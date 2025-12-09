import '../models/text_structure_model.dart';
import '../../enum.dart';
import '../text_parser.dart';

/// 单行 Markdown 分割横线解析器
/// `---`、`- - -`、`* * *`、`_ _ _`
class MarkdownHorizontalRuleParser implements TextParser {
  @override
  int get priority => 4;

  static bool hasMatch(String line) =>
      RegExp(r'^\s*([-*_])(?:\s*\1){2,}\s*$').hasMatch(line);

  @override
  ParseResult parse(ParseContext context) {
    final lineTrim = context.currentLineTrim;
    if (hasMatch(lineTrim)) {
      context.addStructure(
        TextStructure(
          type: TextStructureType.markdownHorizontalRule,
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
