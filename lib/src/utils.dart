abstract final class Utils {
  /// 是否为中文
  static bool isChinese(String content) =>
      RegExp(r'[\u4e00-\u9fa5]').hasMatch(content);
}
