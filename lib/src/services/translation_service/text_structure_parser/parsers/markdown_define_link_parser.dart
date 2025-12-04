import '../models/text_structure_model.dart';
import '../../enum.dart';
import '../text_parser.dart';

/// 单行 Markdown 定义的链接 解析器
/// `[xx]: xxx`
class MarkdownDefineLinkParser implements TextParser {
  static final regex = RegExp(r'^\s*\[([^\]]+)\]:\s*(.+)$');

  @override
  int get priority => 7;

  @override
  ParseResult parse(ParseContext context) {
    final lineTrim = context.currentLineTrim;
    if (regex.hasMatch(lineTrim)) {
      context.addStructure(
        TextStructure(
          type: TextStructureType.markdownDefineLink,
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
