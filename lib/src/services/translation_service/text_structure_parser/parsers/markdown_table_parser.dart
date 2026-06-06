import '../../../../utils.dart';
import '../../enum.dart';
import '../text_parser.dart';

/// Markdown 表格 解析器
class MarkdownTableParser extends RunBlockParser {
  static final RegExp _pattern = RegExp(r'^\s*(\S.*?\|.*\S)\s*$');

  @override
  TextStructureType get blockType => TextStructureType.markdownTable;

  @override
  bool startsBlock(String lineTrim) => _pattern.hasMatch(lineTrim);

  @override
  bool endsAfter(String? nextLineTrim, ParseContext context) =>
      nextLineTrim == null || !_pattern.hasMatch(nextLineTrim);

  @override
  TextStructureType resolveType(ParseContext context) =>
      Utils.hasChinese(context.originalText.join())
      ? TextStructureType.chineseMarkdownTable
      : TextStructureType.markdownTable;
}
