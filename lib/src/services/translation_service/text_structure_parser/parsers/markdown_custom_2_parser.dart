import '../../enum.dart';
import '../text_parser.dart';

/// 单行 Markdown 自定义语法2 `<?xxx` 解析器
/// `<?xxx`
class MarkdownCustom2Parser extends SingleLineParser {
  static final RegExp _pattern = RegExp(r'^\s*\<\?');

  @override
  TextStructureType get type => TextStructureType.markdownCustom2;

  @override
  bool matches(String lineTrim) => _pattern.hasMatch(lineTrim);
}
