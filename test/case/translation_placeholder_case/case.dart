abstract class Case<T> {
  /// 测试文本
  String testText();

  /// 预期
  T expect();
}
