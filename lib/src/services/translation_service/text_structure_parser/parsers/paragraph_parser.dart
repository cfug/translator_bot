import '../../../../utils.dart';
import '../../enum.dart';
import '../text_parser.dart';

/// 整块段落 - 除其他规则以外无法判定的内容 解析器
class ParagraphParser extends RunBlockParser {
  @override
  TextStructureType get blockType => TextStructureType.paragraph;

  /// 段落是兜底块：进入调度即认领当前行。
  @override
  bool startsBlock(String lineTrim) => true;

  /// 段落没有专属起始标记，因此不主动认领任何行（供其他解析器的边界判定）。
  @override
  bool matchesLineStart(String line) => false;

  /// 下一行为空、或能被其他解析器认领为块起始时，段落结束。
  @override
  bool endsAfter(String? nextLineTrim, ParseContext context) =>
      nextLineTrim == null || context.isLineClaimedByOther(nextLineTrim, this);

  @override
  TextStructureType resolveType(ParseContext context) =>
      Utils.isTranslated(context.originalText.join())
      ? TextStructureType.chineseParagraph
      : TextStructureType.paragraph;
}
