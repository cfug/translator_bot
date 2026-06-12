import 'package:googleai_dart/googleai_dart.dart';
import 'package:http/http.dart' as http;

import '../../../prompts/prompts.dart';
import '../../translation_service/translation_exception.dart';
import '../../translation_service/translation_service.dart';
import '../../translation_service/placeholder_translator/translation_response_parser.dart';
import '../model_service.dart';
import 'gemini_model_session.dart';

class GeminiService implements ModelService {
  /// Gemini 协议的模型服务
  ///
  /// 具体模型名与调参内定于本类，外部仅配 [apiKey]。
  ///
  /// 内置模型配置，便于调优与维护；
  /// 会话适配交给 [GeminiModelSession]，本类只负责构造它并调用。
  GeminiService({required String apiKey, required http.Client httpClient})
    : _apiKey = apiKey,
      _client = GoogleAIClient(
        config: GoogleAIConfig(
          baseUrl: 'https://generativelanguage.googleapis.com',
          apiMode: ApiMode.googleAI,
          apiVersion: ApiVersion.v1beta,
          authProvider: ApiKeyProvider(apiKey),
          timeout: const Duration(minutes: 5),
          retryPolicy: const RetryPolicy(
            maxRetries: 3,
            initialDelay: Duration(seconds: 1),
            maxDelay: Duration(seconds: 60),
            jitter: 0.1,
          ),
        ),
        httpClient: httpClient,
      );

  /// 模型客户端
  final GoogleAIClient _client;

  final String _apiKey;

  /// 内定翻译模型
  static const String _model = 'gemini-2.5-flash';

  /// 结构化输出强约束用的 JSON Schema（严格定形为译文块数组）
  /// 由 [TranslationResponseParser] 解包。
  static final Map<String, dynamic> _schema = const Schema(
    type: SchemaType.array,
    nullable: false,
    items: Schema(
      type: SchemaType.object,
      properties: {
        'id': Schema(type: SchemaType.string, nullable: false),
        'indentCount': Schema(type: SchemaType.integer, nullable: false),
        'text': Schema(type: SchemaType.string, nullable: false),
      },
      required: ['id', 'indentCount', 'text'],
    ),
  ).toJson();

  @override
  Future<({String outputText, int totalTokenCount})> translatorChunk(
    String text,
  ) async {
    final session = GeminiModelSession(
      _client,
      model: _model,
      apiKey: _apiKey,
      createRequest: (input) => GenerateContentRequest(
        contents: [Content.text(input)],
        systemInstruction: Content(parts: [TextPart(translatorPrompt)]),
        generationConfig: GenerationConfig(
          temperature: 0.2,
          // topP: 0.2,
          responseMimeType: 'application/json',
          responseSchema: _schema,
        ),
      ),
    );

    try {
      final outputText = await TranslationService(session, text).run();
      return (outputText: outputText, totalTokenCount: session.totalTokens);
    } on TranslationException {
      rethrow;
    } catch (e) {
      throw TranslationException('$e', redact: [_apiKey]);
    }
  }
}
