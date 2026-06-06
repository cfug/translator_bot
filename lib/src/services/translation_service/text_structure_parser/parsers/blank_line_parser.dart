import '../../enum.dart';
import '../text_parser.dart';

/// 单行空行解析器
class BlankLineParser extends SingleLineParser {
  @override
  TextStructureType get type => TextStructureType.blankLine;

  @override
  bool matches(String lineTrim) => lineTrim == '';
}
