/// 翻译异常
///
/// 各模型适配器应在自身边界把 SDK 专属异常（如 Gemini 的 `GenerativeAIException`）映射为本异常。
class TranslationException implements Exception {
  /// 翻译流水线领域异常
  ///
  /// - [message] 错误描述
  const TranslationException(this.message);

  /// 错误描述
  final String message;

  @override
  String toString() => 'TranslationException: $message';
}
