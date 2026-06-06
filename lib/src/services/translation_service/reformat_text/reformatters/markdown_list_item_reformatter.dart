import '../reformatter.dart';

/// Markdown 列表项预处理器
///
/// 在每个列表项（`* xxx`、`- xxx`、`+ xxx`、`1. xxx`）上方补一行空行；
/// 列表项之间不补下方空行，使整段列表保持为一个连续块。
class MarkdownListItemReformatter extends LineMarkerReformatter {
  static final RegExp _pattern = RegExp(r'^\s*([*+\-]|\d+\.)\s+');

  @override
  bool matches(String lineTrimLeft) => _pattern.hasMatch(lineTrimLeft);

  @override
  bool get padAfter => false;
}
