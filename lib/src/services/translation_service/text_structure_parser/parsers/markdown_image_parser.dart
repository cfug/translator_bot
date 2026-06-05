import '../../enum.dart';
import '../text_parser.dart';

/// 单行 Markdown 图片 解析器
/// `![xxx](xxx)`
class MarkdownImageParser extends SingleLineParser {
  static final RegExp _pattern = RegExp(r'!\[([^\]]*)\]\s*\(\s*([^)]+)\s*\)');

  @override
  TextStructureType get type => TextStructureType.markdownImage;

  @override
  bool matches(String lineTrim) => _pattern.hasMatch(lineTrim);
}
