import '../models/text_structure_model.dart';
import '../../enum.dart';
import '../text_parser.dart';

/// 单行 Markdown 自定义语法1 `{:xxx}` 解析器
/// `{:xxx}`
class MarkdownCustom1Parser implements TextParser {
  @override
  int get priority => 10;

  static bool hasMatch(String line) =>
      RegExp(r'\{:\s*([^}]+?)\s*\}').hasMatch(line);

  @override
  ParseResult parse(ParseContext context) {
    final lineTrim = context.currentLineTrim;
    if (hasMatch(lineTrim)) {
      context.addStructure(
        TextStructure(
          type: TextStructureType.markdownCustom1,
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
