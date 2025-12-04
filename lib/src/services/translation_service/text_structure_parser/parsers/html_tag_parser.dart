import '../models/text_structure_model.dart';
import '../../enum.dart';
import '../text_parser.dart';

/// 单行 HTML 标签 `<xxx`、`</xxx` 解析器
/// `<xxx`、`</xxx
class HtmlTagParser implements TextParser {
  static final regex = RegExp(r'^\s*<\/?[a-zA-Z][a-zA-Z0-9-]*');

  @override
  int get priority => 13;

  @override
  ParseResult parse(ParseContext context) {
    final lineTrim = context.currentLineTrim;
    if (regex.hasMatch(lineTrim) && !lineTrim.startsWith('<br')) {
      context.addStructure(
        TextStructure(
          type: TextStructureType.htmlTag,
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
