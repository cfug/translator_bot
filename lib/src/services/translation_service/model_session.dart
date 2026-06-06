import 'models/translation_chunk_model.dart';

/// 模型会话接口
///
/// 会话适配器请置于各自的服务层（如 [GeminiModelSession] 所在位置），
abstract interface class ModelSession {
  /// 发送一批格式化后的待翻译文本，返回该批翻译完成的译文块列表
  ///
  /// - [input] 单批输入文本
  ///
  /// @return 该批的译文块列表
  Future<List<TranslationChunk>> translateBatch(String input);
}
