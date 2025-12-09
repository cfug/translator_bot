import '../../../../utils.dart';
import '../models/text_structure_model.dart';
import '../../enum.dart';
import '../text_parser.dart';

/// 顶部元数据解析器
/// 从 0 行开始 `---` 开头和结尾的部分
class TopMetadataParser implements TextParser {
  @override
  int get priority => 1;

  static bool hasMatch(String line) => line == '---';

  @override
  ParseResult parse(ParseContext context) {
    final lineTrim = context.currentLineTrim;

    /// 顶部元数据 - 开始
    if (context.currentIndex == 0 && hasMatch(lineTrim)) {
      context.currentType = TextStructureType.topMetadata;
      context.startLineIndex = context.currentIndex;
      context.originalText.add(context.currentLine);
      return ParseResult.handled;
    }

    /// 顶部元数据 - 结束
    if (context.currentType == TextStructureType.topMetadata &&
        context.currentIndex != 0 &&
        hasMatch(lineTrim)) {
      context.originalText.add(context.currentLine);

      final isChinese = Utils.isChinese(context.originalText.join());
      final type = isChinese
          ? TextStructureType.chineseTopMetadata
          : TextStructureType.topMetadata;

      context.addStructure(
        TextStructure(
          type: type,
          start: context.startLineIndex,
          end: context.currentIndex,
          originalText: context.originalText,
        ),
      );

      context.reset();
      return ParseResult.handled;
    }

    /// 顶部元数据 - 内容
    if (context.currentType == TextStructureType.topMetadata) {
      context.originalText.add(context.currentLine);
      return ParseResult.handled;
    }

    return ParseResult.notHandled;
  }
}
