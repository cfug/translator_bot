import '../models/text_structure_model.dart';
import '../../enum.dart';
import '../text_parser.dart';

/// 单行 Markdown 图片 解析器
/// `![xxx](xxx)`
class MarkdownImageParser implements TextParser {
  static final regex = RegExp(r'!\[([^\]]*)\]\s*\(\s*([^)]+)\s*\)');

  @override
  int get priority => 8;

  @override
  ParseResult parse(ParseContext context) {
    final lineTrim = context.currentLineTrim;
    if (regex.hasMatch(lineTrim)) {
      context.addStructure(
        TextStructure(
          type: TextStructureType.markdownImage,
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
