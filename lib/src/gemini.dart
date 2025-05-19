import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

import 'prompts/prompts.dart';
import 'translate_text_chunk.dart';

class GeminiService {
  GeminiService({required String apiKey, required http.Client httpClient})
    : _translatorModel = GenerativeModel(
        model: translatorModel,
        apiKey: apiKey,
        systemInstruction: Content.system(translatorPrompt),
        generationConfig: GenerationConfig(
          maxOutputTokens: 8192,
          temperature: 0.5,
          topP: 0.5,
          responseMimeType: 'application/json',
        ),
        httpClient: httpClient,
      );

  static const String translatorModel = 'models/gemini-2.0-flash';

  final GenerativeModel _translatorModel;

  /// 调用 translator 分块处理
  ///
  /// - [text] 需要处理的内容
  ///
  /// 捕获异常: [GenerativeAIException].
  ///
  /// @return
  /// - [outputText] 全部输出内容
  /// - [totalTokenCount] 当前消耗的总 Token
  Future<({String outputText, int totalTokenCount})?> translatorChunk(
    String text,
  ) async {
    /// 开始处理
    final chat = _translatorModel.startChat();

    /// 分块翻译
    final outputText = await TranslateTextChunk(chat, text).run();

    /// 总消耗 Token
    final countTokensResponse = await _translatorModel.countTokens(
      chat.history,
    );
    return (
      outputText: outputText,
      totalTokenCount: countTokensResponse.totalTokens,
    );
  }
}
