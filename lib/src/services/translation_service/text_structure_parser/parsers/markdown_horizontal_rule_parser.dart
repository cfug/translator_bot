import '../models/text_structure_model.dart';
import '../../enum.dart';
import '../text_parser.dart';

/// 单行 Markdown 分割横线解析器
/// `---`、`- - -`、`* * *`、`_ _ _`
class MarkdownHorizontalRuleParser implements TextParser {
  static final regex = RegExp(r'^\s*([-*_])(?:\s*\1){2,}\s*$');
  @override
  int get priority => 4;

  @override
  ParseResult parse(ParseContext context) {
    final lineTrim = context.currentLineTrim;
    if (regex.hasMatch(lineTrim)) {
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
