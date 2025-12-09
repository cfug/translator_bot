import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

import '../prompts/prompts.dart';
import 'translation_service/models/translation_chunk_model.dart';
import 'translation_service/translation_service.dart';

class GeminiService {
  GeminiService({required String apiKey, required http.Client httpClient})
    : _translatorModel = GenerativeModel(
        model: translatorModel,
        apiKey: apiKey,
        systemInstruction: Content.system(translatorPrompt),
        // TODO: 是否需要进行思考
        // "generationConfig": {
        //   "thinkingConfig": {
        //     "thinkingBudget": 0
        //   }
        // }
        generationConfig: GenerationConfig(
          temperature: 0.2,
          // topP: 0.2,
          responseMimeType: 'application/json',
          responseSchema: translationChunkResponseSchema,
        ),
        httpClient: httpClient,
      );

  static const String translatorModel = 'models/gemini-2.5-flash';

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
  Future<({String outputText, int totalTokenCount})> translatorChunk(
    String text,
  ) async {
    /// 开始处理
    final chat = _translatorModel.startChat();

    /// 运行翻译
    final outputText = await TranslationService(chat, text).run();

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
