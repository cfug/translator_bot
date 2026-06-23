import '../placeholder_translator/translation_applier.dart';

/// 译文与原文相同时的占位省略策略
///
/// 在回填阶段（[TranslationApplier]），若某占位块的译文等于原文，
/// 按此策略决定如何省略其回填，避免产生 “原文 + 完全相同译文” 的重复。
enum OmitMode {
  /// 不省略，照常回填（默认）
  ///
  /// 适用于原文被注释、占位行是唯一有效行的结构
  /// （front matter / aside `:::` / liquid tab / html tab 等）
  /// 这些结构跳过回填会直接删掉字段/标签，且本就不产生可见重复。
  never,

  /// 整行占位删除
  ///
  /// 适用于 “原文行保留 + 下方另起译文行” 的结构（段落 / 列表项 / 标题 等），
  /// 以及表体译文行（整行表格所有占位都与原文相同时整行删除）。
  /// 删除占位行的同时，删除其上方那一空行。
  dropLine,

  /// 表头单元格收敛
  ///
  /// 把 `<t>原文</t><t>占位</t>` 收敛为 `<t>原文</t>`（仅删译文 `<t>` 段）。
  ///
  /// TODO(Amos)：属于独立处理的业务逻辑，暂时一同处理，后续如果出现更多其他场景可考虑迁移为独立处理。
  collapseTableCell,
}

/// 翻译块数据
class TranslationChunk {
  /// 翻译块数据
  const TranslationChunk({
    required this.id,
    required this.indentCount,
    required this.text,
    this.omitMode = OmitMode.never,
  });

  factory TranslationChunk.fromJson(Map<String, dynamic> json) {
    return TranslationChunk(
      id: json['id'] as String,
      indentCount: _parseIndentCount(json['indentCount']),
      text: json['text'] as String,
    );
  }

  /// 容错解析 [indentCount] 为 [int]
  ///
  /// 模型有时把整数返回成字符串（如 `"2"`）或浮点（如 `2.0`）
  static int _parseIndentCount(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = num.tryParse(value.trim());
      if (parsed != null) return parsed.toInt();
    }
    throw FormatException('indentCount 无法解析为 int', value);
  }

  /// 翻译块 ID
  ///
  /// 用于替换原文翻译占位的 ID
  final String id;

  /// 缩进计数
  final int indentCount;

  /// 内容（需要翻译、已翻译）
  final String text;

  /// 译文与原文相同时的占位省略策略
  ///
  /// 仅在原文块上有意义（由占位 chunker 按结构标注），
  /// AI 返回的译文块默认为 [OmitMode.never]。
  /// 属于流水线内存数据，不参与 [TranslationChunk.fromJson] / [toJson] 的 AI 格式。
  final OmitMode omitMode;

  Map<String, dynamic> toJson() {
    return {'id': id, 'indentCount': indentCount, 'text': text};
  }

  TranslationChunk copyWith({
    String? id,
    String? text,
    int? indentCount,
    OmitMode? omitMode,
  }) {
    return TranslationChunk(
      id: id ?? this.id,
      indentCount: indentCount ?? this.indentCount,
      text: text ?? this.text,
      omitMode: omitMode ?? this.omitMode,
    );
  }

  @override
  String toString() =>
      '\nTranslationChunk(\n'
      '  id: $id,\n'
      '  indentCount: $indentCount,\n'
      '  text: $text,\n'
      '  omitMode: $omitMode,\n'
      ')';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TranslationChunk &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          indentCount == other.indentCount &&
          text == other.text &&
          omitMode == other.omitMode;

  @override
  int get hashCode => Object.hashAll([id, indentCount, text, omitMode]);
}
