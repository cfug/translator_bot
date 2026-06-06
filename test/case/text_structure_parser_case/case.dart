abstract class Case {
  /// 测试文本
  String testText();

  /// 预期结构（紧凑表示 `type:start-end` 列表）
  List<String> expectStructures();
}
