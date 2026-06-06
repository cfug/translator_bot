import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

import '../../../prompts/prompts.dart';
import '../model_service.dart';
import '../../translation_service/translation_exception.dart';
import '../../translation_service/translation_service.dart';
import 'gemini_model_session.dart';

class GeminiService implements ModelService {
  /// Gemini 协议的模型服务
  ///
  /// 内置模型配置，便于调优与维护；
  /// 会话适配交给 [GeminiModelSession]，本类只负责构造它并调用。
  GeminiService({required String apiKey, required http.Client httpClient})
    : _client = GenerativeModel(
        model: _model,
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
          responseSchema: Schema.array(
            nullable: false,

            /// 结构化输出强约束用的 JSON Schema，
            /// 由 [TranslationResponseParser] 解包。
            items: Schema.object(
              requiredProperties: ['id', 'indentCount', 'text'],
              properties: {
                'id': Schema.string(nullable: false),
                'indentCount': Schema.integer(nullable: false),
                'text': Schema.string(nullable: false),
              },
            ),
          ),
        ),
        httpClient: httpClient,
      );

  /// 模型客户端
  final GenerativeModel _client;

  static const String _model = 'models/gemini-2.5-flash';

  /// 调用 translator 分块处理
  ///
  /// - [text] 需要处理的内容
  ///
  /// @return
  /// - [outputText] 全部输出内容
  /// - [totalTokenCount] 当前消耗的总 Token
  @override
  Future<({String outputText, int totalTokenCount})> translatorChunk(
    String text,
  ) async {
    try {
      final chat = _client.startChat();
      final session = GeminiModelSession(chat);

      /// 运行翻译
      final outputText = await TranslationService(session, text).run();

      /// 总消耗 Token
      final countTokensResponse = await _client.countTokens(chat.history);
      return (
        outputText: outputText,
        totalTokenCount: countTokensResponse.totalTokens,
      );
    } on GenerativeAIException catch (e) {
      throw TranslationException('$e');
    }
  }
}
