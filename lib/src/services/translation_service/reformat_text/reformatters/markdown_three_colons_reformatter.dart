import '../reformatter.dart';

/// Markdown 自定义 `:::` 块语法预处理器
///
/// 在 `:::` 行上方和下方各补一行空行。
class MarkdownThreeColonsReformatter extends LineMarkerReformatter {
  @override
  bool matches(String lineTrimLeft) => lineTrimLeft.startsWith(':::');
}
