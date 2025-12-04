import '../../../../utils.dart';
import '../models/text_structure_model.dart';
import '../../enum.dart';
import '../text_parser.dart';

/// 单行 Liquid 语法 `{% xxx` 解析器
/// `{% xxx`
class Liquid1Parser implements TextParser {
  static final regex = RegExp(r'^\s*\{%');

  @override
  int get priority => 12;

  @override
  ParseResult parse(ParseContext context) {
    final lineTrim = context.currentLineTrim;
    if (regex.hasMatch(lineTrim)) {
      final isChinese = Utils.isChinese(context.currentLine);
      context.addStructure(
        TextStructure(
          type: isChinese
              ? TextStructureType.chinsesLiquid1
              : TextStructureType.liquid1,
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
