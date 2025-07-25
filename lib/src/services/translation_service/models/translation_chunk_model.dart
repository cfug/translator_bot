/// 翻译块数据
class TranslationChunk {
  /// 翻译块数据
  const TranslationChunk({
    required this.id,
    required this.indentCount,
    required this.text,
  });

  factory TranslationChunk.fromJson(Map json) {
    return TranslationChunk(
      id: json['id'],
      indentCount: json['indentCount'],
      text: json['text'],
    );
  }

  /// 翻译块 ID
  ///
  /// 用于替换原文翻译占位的 ID
  final String id;

  /// 缩进计数
  final int indentCount;

  /// 内容（需要翻译、已翻译）
  final String text;

  Map<String, dynamic> toJson() {
    return {'id': id, 'indentCount': indentCount, 'text': text};
  }

  TranslationChunk copyWith({String? id, String? text, int? indentCount}) {
    return TranslationChunk(
      id: id ?? this.id,
      indentCount: indentCount ?? this.indentCount,
      text: text ?? this.text,
    );
  }

  @override
  String toString() =>
      '\nTranslationChunk(\n'
      '  id: $id,\n'
      '  indentCount: $indentCount,\n'
      '  text: $text,\n'
      ')';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranslationChunk &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          indentCount == other.indentCount &&
          text == other.text;

  @override
  int get hashCode => Object.hashAll([id, indentCount, text]);
}
