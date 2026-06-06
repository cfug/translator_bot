import '../reformatter.dart';

/// Liquid `{% comment %}` / `{% endcomment %}` 块语法预处理器
///
/// 在注释起止行（含 `{%-` 连字符变体）上方和下方各补一行空行。
class LiquidCommentReformatter extends LineMarkerReformatter {
  static final RegExp _pattern = RegExp(r'^\{%-? (end)?comment');

  @override
  bool matches(String lineTrimLeft) => _pattern.hasMatch(lineTrimLeft);
}
