import 'package:google_generative_ai/google_generative_ai.dart';

import '../../translation_service/model_session.dart';
import '../../translation_service/models/translation_chunk_model.dart';
import '../../translation_service/placeholder_translator/translation_response_parser.dart';

/// Gemini 协议的会话适配器
class GeminiModelSession implements ModelSession {
  /// Gemini 协议的会话适配器
  ///
  /// - [chat] Gemini 会话
  /// - [parser] 响应解析器
  const GeminiModelSession(
    this.chat, {
    TranslationResponseParser parser = const TranslationResponseParser(),
  }) : _parser = parser;

  final ChatSession chat;
  final TranslationResponseParser _parser;

  @override
  Future<List<TranslationChunk>> translateBatch(String input) async {
    final response = await chat.sendMessage(Content.text(input));
    return _parser.parse(response.text ?? '');
  }
}
