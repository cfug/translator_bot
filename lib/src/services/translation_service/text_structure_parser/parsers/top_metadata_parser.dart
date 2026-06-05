import '../../../../utils.dart';
import '../../enum.dart';
import '../text_parser.dart';

/// 顶部元数据解析器
/// 从 0 行开始 `---` 开头和结尾的部分
class TopMetadataParser extends DelimitedBlockParser {
  @override
  TextStructureType get blockType => TextStructureType.topMetadata;

  @override
  bool isBegin(String lineTrim) => lineTrim == '---';

  /// 仅文档首行允许开启顶部元数据。
  @override
  bool canOpenAt(ParseContext context) => context.currentIndex == 0;

  @override
  TextStructureType resolveType(ParseContext context) =>
      Utils.isChinese(context.originalText.join())
      ? TextStructureType.chineseTopMetadata
      : TextStructureType.topMetadata;
}
