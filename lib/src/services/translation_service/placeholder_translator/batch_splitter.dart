import '../models/translation_chunk_model.dart';
import 'chunk_input_formatter.dart';

/// 译文块分批器
///
/// 将译文块列表按 [maxInputCount] 上限切分为多个批次输入文本,
/// 防止单次输入过大导致 AI 输出超出限制。
///
/// 切分策略：依次累加每个块的格式化输入,一旦累计长度达到上限、或到达最后一个块，即收口当前批。
class BatchSplitter {
  const BatchSplitter({
    this.maxInputCount = 10 * 1024,
    this.formatter = const ChunkInputFormatter(),
  });

  /// 最大输入计数（防止输出超出限制）
  final int maxInputCount;

  /// 单块输入格式化器
  final ChunkInputFormatter formatter;

  /// 将 [chunks] 切分为多个批次输入文本。
  ///
  /// - [chunks] 待翻译的译文 ID 占位块数据
  ///
  /// @return 分批后的输入文本列表（空输入返回空列表）
  List<String> split(List<TranslationChunk> chunks) {
    /// 需要分批翻译的文本
    final batchInputTextList = <String>[];

    /// 分批次翻译
    /// 处理成 AI 需要输入的格式内容
    var batchText = '';
    for (var i = 0; i < chunks.length; i++) {
      final chunk = chunks[i];
      batchText += formatter.format(chunk);

      /// 分批输入
      if (batchText.length >= maxInputCount || i == chunks.length - 1) {
        if (batchText != '') {
          batchInputTextList.add(batchText);
          batchText = '';
        }
      }
    }

    return batchInputTextList;
  }
}
