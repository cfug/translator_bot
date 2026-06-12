import 'package:http/http.dart' as http;
import 'package:openai_dart/openai_dart.dart';

import '../../../prompts/prompts.dart';
import '../../translation_service/translation_exception.dart';
import '../../translation_service/translation_service.dart';
import '../../translation_service/placeholder_translator/translation_response_parser.dart';
import '../model_service.dart';
import 'openai_model_session.dart';

class OpenAiService implements ModelService {
  /// OpenAI 协议的模型服务
  ///
  /// “OpenAI 协议” 指 OpenAI 兼容的 Chat Completions 接口，并不限于 GPT 模型；
  /// 具体模型名与调参内定于本类，外部仅配 [baseUrl] / [apiKey]。
  ///
  /// 内置模型配置，便于调优与维护；
  /// 会话适配交给 [OpenAiModelSession]，本类只负责构造它并调用。
  OpenAiService({
    required String apiKey,
    required String baseUrl,
    required http.Client httpClient,
  }) : _apiKey = apiKey,
       _client = OpenAIClient(
         config: OpenAIConfig(
           baseUrl: baseUrl,
           authProvider: ApiKeyProvider(apiKey),
           timeout: const Duration(minutes: 10),
           connectTimeout: const Duration(seconds: 30),
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
  final OpenAIClient _client;

  final String _apiKey;

  /// 内定翻译模型
  static const String _model = 'gpt-5.4-mini';

  /// 结构化输出强约束用的 JSON Schema（严格定形为 `{translations:[...]}` 对象)
  /// 由 [TranslationResponseParser] 解包。
  static const Map<String, dynamic> _schema = {
    'type': 'object',
    'properties': {
      'translations': {
        'type': 'array',
        'items': {
          'type': 'object',
          'properties': {
            'id': {'type': 'string'},
            'indentCount': {'type': 'integer'},
            'text': {'type': 'string'},
          },
          'required': ['id', 'indentCount', 'text'],
          'additionalProperties': false,
        },
      },
    },
    'required': ['translations'],
    'additionalProperties': false,
  };

  @override
  Future<({String outputText, int totalTokenCount})> translatorChunk(
    String text,
  ) async {
    final session = OpenAiModelSession(
      _client,
      apiKey: _apiKey,
      createRequest: (input) => ChatCompletionCreateRequest(
        model: _model,
        temperature: 0.2,
        messages: [
          ChatMessage.system(translatorPrompt),
          ChatMessage.user(input),
        ],
        responseFormat: ResponseFormat.jsonSchema(
          name: 'translation',
          schema: _schema,
          strict: true,
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
