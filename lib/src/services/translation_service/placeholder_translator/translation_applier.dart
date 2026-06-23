import '../models/translation_chunk_model.dart';
import 'chunk_input_formatter.dart';

/// 译文回填器
///
/// 把翻译结果按译文块 ID 替换回占位后的原始行，生成最终文本。
/// 每个译文块的内容按其缩进计数为每一行补齐缩进空格并 `trim`。
///
/// 输入阶段（[ChunkInputFormatter]）把多行内容的换行折叠成 `\n`，
/// 此处把 `\n` 还原为真换行。
///
/// 当传入原文块（[apply] 的 `originalPlaceholderData`）时，
/// 对 “译文经规范化后等于原文” 的占位，按其 [TranslationChunk.omitMode] 省略回填，
/// 避免 “原文 + 完全相同译文” 的重复。
class TranslationApplier {
  const TranslationApplier();

  /// 应用翻译结果
  ///
  /// - [placeholderOriginalLines] 译文 ID 占位修改后的原始行内容
  /// - [translatedPlaceholderData] 已翻译完成的译文 ID 占位块数据
  /// - [originalPlaceholderData] 占位阶段的原文块
  ///   （携带原文与 [TranslationChunk.omitMode]），用于判定并省略 “译文==原文” 的回填。
  ///
  /// @return 翻译后的文本,`null`: 翻译为空
  String? apply(
    List<String> placeholderOriginalLines,
    List<TranslationChunk> translatedPlaceholderData, {
    List<TranslationChunk> originalPlaceholderData = const [],
  }) {
    if (translatedPlaceholderData.isEmpty) return null;

    /// ID -> 标准格式的译文
    final replacements = <String, String>{};
    for (final chunk in translatedPlaceholderData) {
      replacements.putIfAbsent(chunk.id, () => _formatTranslation(chunk));
    }

    /// ID -> 原文块（提供省略策略与原文，用于判定 “译文==原文”）
    final originalById = <String, TranslationChunk>{};
    for (final chunk in originalPlaceholderData) {
      originalById.putIfAbsent(chunk.id, () => chunk);
    }

    /// 译文等于原文、且策略非 [OmitMode.never] 的占位 ID
    final unchangedIds = <String>{};
    for (final translated in translatedPlaceholderData) {
      final original = originalById[translated.id];
      if (original == null || original.omitMode == OmitMode.never) continue;
      if (_isUnchanged(translated.text, original.text)) {
        unchangedIds.add(translated.id);
      }
    }

    /// 全部已知占位 ID（原文与译文合并），用于在每行中定位占位
    final knownIds = <String>{...replacements.keys, ...originalById.keys};
    final idPattern = RegExp(knownIds.map(RegExp.escape).join('|'));

    final result = <String>[];
    for (final line in placeholderOriginalLines) {
      /// 定位本行的占位 ID（可能多个，且不保证译文块与原文块 ID 集完全相同）
      final lineIds = idPattern.allMatches(line).map((m) => m[0]!).toList();

      /// 无占位的原始行原样保留
      if (lineIds.isEmpty) {
        result.add(line);
        continue;
      }

      /// 删整行：本行占位全部为 [OmitMode.dropLine] 且全部 “译文==原文”。
      /// （表体译文行多个占位时，须整行都等于原文才删除）。
      final isDroppableLine =
          lineIds.every(
            (id) => originalById[id]?.omitMode == OmitMode.dropLine,
          ) &&
          lineIds.every(unchangedIds.contains);
      if (isDroppableLine) {
        /// 一并删除占位行上方那一空行（占位 chunker 在占位行前插入的间隔）
        if (result.isNotEmpty && result.last.trim().isEmpty) {
          result.removeLast();
        }
        continue;
      }

      /// 否则回填本行
      var filled = line;

      /// 表头单元格收敛：删除 “译文==原文” 的 `<t>{id}</t>` 段，仅留 `<t>原文</t>`
      ///
      /// TODO(Amos)：属于独立处理的业务逻辑，暂时一同处理，后续如果出现更多其他场景可考虑迁移为独立处理。
      for (final id in lineIds) {
        if (originalById[id]?.omitMode == OmitMode.collapseTableCell &&
            unchangedIds.contains(id)) {
          filled = filled.replaceAll('<t>$id</t>', '');
        }
      }

      /// 其余占位按 ID 回填，译文缺失（AI 漏译）的占位原样保留
      filled = filled.replaceAllMapped(
        idPattern,
        (match) => replacements[match[0]] ?? match[0]!,
      );

      result.add(filled);
    }

    return result.join('\n');
  }

  /// 把译文块格式化为标准回填文本
  ///
  /// 还原折叠的 `\n` -> 真换行、`trim`、按 [TranslationChunk.indentCount]
  /// 为每行补齐前导空格。
  String _formatTranslation(TranslationChunk chunk) {
    return chunk.text
        .replaceAll(r'\n', '\n')
        .trim()
        .split('\n')
        .map((line) => '${" " * chunk.indentCount}${line.trim()}')
        .join('\n');
  }

  /// 译文经规范化后是否与原文等值
  ///
  /// 规范化：还原折叠的 `\n` -> 真换行、逐行 `trim`、再 join。
  /// 忽略缩进与行尾空白差异（例如 `iOS` == `iOS` 成立）。
  bool _isUnchanged(String translated, String original) {
    String normalize(String value) => value
        .replaceAll(r'\n', '\n')
        .split('\n')
        .map((line) => line.trim())
        .join('\n');
    return normalize(translated) == normalize(original);
  }
}
