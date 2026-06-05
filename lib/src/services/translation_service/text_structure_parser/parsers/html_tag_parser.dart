import '../../enum.dart';
import '../text_parser.dart';

/// 单行 HTML 标签 `<xxx`、`</xxx` 解析器
/// `<xxx`、`</xxx`
class HtmlTagParser extends SingleLineParser {
  static final RegExp _pattern = RegExp(r'^\s*<\/?[a-zA-Z][a-zA-Z0-9-]*');

  @override
  TextStructureType get type => TextStructureType.htmlTag;

  @override
  bool matches(String lineTrim) =>
      _pattern.hasMatch(lineTrim) && !lineTrim.startsWith('<br');
}
