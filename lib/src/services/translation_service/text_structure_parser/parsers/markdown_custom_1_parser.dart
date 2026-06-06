import '../../enum.dart';
import '../text_parser.dart';

/// 单行 Markdown 自定义语法1 `{:xxx}` 解析器
/// `{:xxx}`
class MarkdownCustom1Parser extends SingleLineParser {
  static final RegExp _pattern = RegExp(r'\{:\s*([^}]+?)\s*\}');

  @override
  TextStructureType get type => TextStructureType.markdownCustom1;

  @override
  bool matches(String lineTrim) => _pattern.hasMatch(lineTrim);
}
