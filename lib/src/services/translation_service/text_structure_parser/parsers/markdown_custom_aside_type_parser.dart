import '../../../../utils.dart';
import '../../enum.dart';
import '../text_parser.dart';

/// 单行 Markdown 自定义 Aside 语法 解析器
/// `:::类型 标题`
class MarkdownCustomAsideTypeParser extends SingleLineParser {
  static final RegExp _pattern = RegExp(r'^\s*(:::)\s*([a-zA-Z0-9-]*)\s*(.*)$');

  /// 占位：实际类型由 [resolveType] 依据捕获组判定。
  @override
  TextStructureType get type => TextStructureType.markdownCustomAsideEnd;

  @override
  bool matches(String lineTrim) => _pattern.hasMatch(lineTrim);

  @override
  TextStructureType resolveType(ParseContext context) {
    final match = _pattern.firstMatch(context.currentLineTrim);
    // group(1) 必为 ::: 界定符
    final hasType = (match?.group(2)?.trim() ?? '') != '';
    final hasTitle = (match?.group(3)?.trim() ?? '') != '';

    if (hasType && hasTitle) {
      /// `:::类型 标题`（标记中文）
      return Utils.isChinese(context.currentLine)
          ? TextStructureType.chineseMarkdownCustomAsideTypeTitle
          : TextStructureType.markdownCustomAsideTypeTitle;
    } else if (hasType) {
      /// `:::类型`
      return TextStructureType.markdownCustomAsideType;
    }

    /// `:::`（块结束）
    return TextStructureType.markdownCustomAsideEnd;
  }
}
