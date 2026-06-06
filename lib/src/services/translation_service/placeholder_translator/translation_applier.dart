import '../models/translation_chunk_model.dart';
import 'chunk_input_formatter.dart';

/// 译文回填器
///
/// 把翻译结果按译文块 ID 替换回占位后的原始行，生成最终文本。
/// 每个译文块的内容按其缩进计数为每一行补齐前导空格并 `trim`。
///
/// 输入阶段（[ChunkInputFormatter]）把多行内容的换行折叠成 `\n`，
/// 此处把 `\n` 还原为真换行。
class TranslationApplier {
  const TranslationApplier();

  /// 应用翻译结果
  ///
  /// - [placeholderOriginalLines] 译文 ID 占位修改后的原始行内容
  /// - [translatedPlaceholderData] 已翻译完成的译文 ID 占位块数据
  ///
  /// @return 翻译后的文本,`null`: 翻译为空
  String? apply(
    List<String> placeholderOriginalLines,
    List<TranslationChunk> translatedPlaceholderData,
  ) {
    if (translatedPlaceholderData.isEmpty) return null;

    /// ID -> 标准格式的译文
    final replacements = <String, String>{};
    for (final chunk in translatedPlaceholderData) {
      replacements.putIfAbsent(
        chunk.id,
        () => chunk.text
            .replaceAll(r'\n', '\n')
            .trim()
            .split('\n')
            .map((line) => '${" " * chunk.indentCount}${line.trim()}')
            .join('\n'),
      );
    }

    /// 由全部 ID 构成的交替正则，一次扫描全文完成替换
    final pattern = RegExp(replacements.keys.map(RegExp.escape).join('|'));
    final result = placeholderOriginalLines.join('\n');
    return result.replaceAllMapped(pattern, (match) => replacements[match[0]]!);
  }
}
