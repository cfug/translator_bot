import '../../enum.dart';

/// 文本结构
class TextStructure {
  /// 文本结构
  const TextStructure({
    required this.type,
    required this.start,
    required this.end,
    required this.originalText,
  });

  /// 文本结构类型
  final TextStructureType type;

  /// 起始行号（从 0 开始）
  final int start;

  /// 结束行号
  final int end;

  /// 原始文本行
  final List<String> originalText;

  @override
  String toString() =>
      '\nTextStructure(\n'
      '  type: $type, start: $start, end: $end,\n'
      '  originalText: $originalText,\n'
      ')';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TextStructure || runtimeType != other.runtimeType) {
      return false;
    }
    if (type != other.type || start != other.start || end != other.end) {
      return false;
    }
    if (originalText.length != other.originalText.length) return false;
    for (var i = 0; i < originalText.length; i++) {
      if (originalText[i] != other.originalText[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode =>
      Object.hash(type, start, end, Object.hashAll(originalText));
}
