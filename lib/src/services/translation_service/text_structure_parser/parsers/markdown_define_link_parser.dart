import '../../enum.dart';
import '../text_parser.dart';

/// 单行 Markdown 定义的链接 解析器
/// `[xx]: xxx`
class MarkdownDefineLinkParser extends SingleLineParser {
  static final RegExp _pattern = RegExp(r'^\s*\[([^\]]+)\]:\s*(.+)$');

  @override
  TextStructureType get type => TextStructureType.markdownDefineLink;

  @override
  bool matches(String lineTrim) => _pattern.hasMatch(lineTrim);
}
