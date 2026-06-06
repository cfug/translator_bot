import '../../../../utils.dart';
import '../../enum.dart';
import '../text_parser.dart';

/// 单行 Liquid 语法 `{% xxx` 解析器
/// `{% xxx`
class Liquid1Parser extends SingleLineParser {
  static final RegExp _pattern = RegExp(r'^\s*\{%');

  @override
  TextStructureType get type => TextStructureType.liquid1;

  @override
  bool matches(String lineTrim) => _pattern.hasMatch(lineTrim);

  @override
  TextStructureType resolveType(ParseContext context) =>
      Utils.hasChinese(context.currentLine)
      ? TextStructureType.chinsesLiquid1
      : TextStructureType.liquid1;
}
