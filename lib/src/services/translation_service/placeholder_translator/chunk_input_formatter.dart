import '../models/translation_chunk_model.dart';

/// 译文块输入格式化器
///
/// 把单个 [TranslationChunk] 格式化为 AI 需要的 `<INPUT>...</INPUT>` 输入格式。
/// 多行内容的换行被折叠为字面 `\n`，保证一个块占一段输入。
class ChunkInputFormatter {
  const ChunkInputFormatter();

  /// 格式化单个译文块为 AI 输入文本。
  ///
  /// - [chunk] 单个需要处理的译文 ID 占位块数据
  ///
  /// @return 格式化后的内容
  String format(TranslationChunk chunk) {
    return '<INPUT>\n'
        'id: ${chunk.id}\n'
        'indentCount: ${chunk.indentCount}\n'
        'text: ${chunk.text.split('\n').join('\\n')}\n'
        '</INPUT>\n'
        '\n';
  }
}
