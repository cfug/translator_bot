import '../../../../utils.dart';
import '../../enum.dart';
import '../text_parser.dart';

/// Markdown 列表项 - 多行内容 解析器
/// `* xxx`、`- xxx`、`+ xxx`、`1. xxx`
class MarkdownListItemParser extends RunBlockParser {
  static final RegExp _pattern = RegExp(r'^\s*([*\-+]|\d+\.)\s+(.+)$');

  @override
  TextStructureType get blockType => TextStructureType.markdownListItem;

  @override
  bool startsBlock(String lineTrim) => _pattern.hasMatch(lineTrim);

  /// 下一行只要能被任意解析器认领（空行、代码块、另一个列表项、标题……）
  /// 即结束当前列表项；否则视为本项的续行继续累积。
  @override
  bool endsAfter(String? nextLineTrim, ParseContext context) =>
      nextLineTrim == null || context.isLineClaimedByAny(nextLineTrim);

  @override
  TextStructureType resolveType(ParseContext context) =>
      Utils.isTranslated(context.originalText.join())
      ? TextStructureType.chineseMarkdownListItem
      : TextStructureType.markdownListItem;
}
