import '../../../../utils.dart';
import '../../enum.dart';
import '../text_parser.dart';

/// Markdown 标题解析器
/// `# xxx`
class MarkdownTitleParser extends SingleLineParser {
  static final RegExp _pattern = RegExp(r'^\s*#{1,6}\s+.+$');

  @override
  TextStructureType get type => TextStructureType.markdownTitle;

  @override
  bool matches(String lineTrim) => _pattern.hasMatch(lineTrim);

  @override
  TextStructureType resolveType(ParseContext context) =>
      Utils.isChinese(context.currentLine)
      ? TextStructureType.chineseMarkdownTitle
      : TextStructureType.markdownTitle;
}
