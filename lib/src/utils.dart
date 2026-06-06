abstract final class Utils {
  /// 是否包含中文字符（含任意一个即为真）
  static bool hasChinese(String content) => _hanRegExp.hasMatch(content);

  /// 是否为 `已翻译（中文）` 文本
  ///
  /// 与 [hasChinese] 的区别：
  /// 本方法基于 `有意义字符` 的中文占比判定，
  /// 用于可能存在大量文本的块（段落 / 列表项）的中文变体识别。
  ///
  /// 避免以英文为主、仅夹少量中文术语的 **原文** 被误判为已翻译而漏译。
  ///
  /// 同时保留对 “中文为主、夹少量英文标识符” 译文（如 `使用 Provider`）的正确识别。
  ///
  /// `有意义字符` 仅计中文与字母，忽略空白、标点、数字、Markdown 语法符号等，
  /// 当不含任何有意义字符时返回 `false`（视为未翻译，确保后续会被翻译）。
  static bool isTranslated(String content) {
    final hanCount = _hanRegExp.allMatches(content).length;
    if (hanCount == 0) return false;
    final latinCount = _latinRegExp.allMatches(content).length;
    final meaningful = hanCount + latinCount;
    if (meaningful == 0) return false;
    return hanCount / meaningful >= _translatedThreshold;
  }

  /// 判定 `已翻译` 所需的中文占比阈值
  ///
  /// 取 0.1：长英文原文夹个别中文词（占比远低于 0.1）-> 视为原文待翻译；
  /// 中文为主夹少量英文标识符（占比通常高于 0.1）-> 视为译文跳过。
  static const double _translatedThreshold = 0.1;

  static final RegExp _hanRegExp = RegExp(r'[\u4e00-\u9fa5]');
  static final RegExp _latinRegExp = RegExp(r'[a-zA-Z]');

  static const emojiGap = '&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;';
}
