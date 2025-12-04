import '../models/text_structure_model.dart';
import '../../enum.dart';
import '../text_parser.dart';

/// 单行空行解析器
class BlankLineParser implements TextParser {
  @override
  int get priority => 3;

  @override
  ParseResult parse(ParseContext context) {
    if (context.currentLineTrim == '') {
      context.addStructure(
        TextStructure(
          type: TextStructureType.blankLine,
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
