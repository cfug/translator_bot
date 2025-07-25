import '../enum.dart';

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

  TextStructure copyWith({
    TextStructureType? type,
    int? start,
    int? end,
    List<String>? originalText,
    List<String>? plainText,
    String? syntaxPrefix,
    String? syntaxSuffix,
  }) {
    return TextStructure(
      type: type ?? this.type,
      start: start ?? this.start,
      end: end ?? this.end,
      originalText: originalText ?? this.originalText,
    );
  }

  @override
  String toString() =>
      '\nTextStructure(\n'
      '  type: $type, start: $start, end: $end,\n'
      '  originalText: $originalText,\n'
      ')';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextStructure &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          start == other.start &&
          end == other.end &&
          originalText == other.originalText;

  @override
  int get hashCode => Object.hashAll([type, start, end, originalText]);
}
