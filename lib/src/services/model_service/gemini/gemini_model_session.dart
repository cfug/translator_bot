import 'package:googleai_dart/googleai_dart.dart';

import '../../translation_service/model_session.dart';
import '../../translation_service/models/translation_chunk_model.dart';
import '../../translation_service/placeholder_translator/translation_response_parser.dart';
import '../../translation_service/translation_exception.dart';

typedef GeminiRequestBuilder = GenerateContentRequest Function(String input);

class GeminiModelSession implements ModelSession {
  /// Gemini 协议的会话适配器
  ///
  /// - [client] 模型客户端
  /// - [model] 模型名
  /// - [apiKey] 仅用于把错误信息里的密钥脱敏
  /// - [createRequest] 构造请求的函数，接收每批输入文本，返回完整的请求对象（包含系统指令、生成配置等）
  /// - [parser] 响应解析器
  GeminiModelSession(
    this.client, {
    required this.model,
    String apiKey = '',
    required GeminiRequestBuilder createRequest,
    TranslationResponseParser parser = const TranslationResponseParser(),
  }) : _apiKey = apiKey,
       _createRequest = createRequest,
       _parser = parser;

  final GoogleAIClient client;
  final String model;
  final String _apiKey;
  final GeminiRequestBuilder _createRequest;
  final TranslationResponseParser _parser;

  int _totalTokens = 0;

  /// 累计消耗的总 Token（来自各次响应的 `usageMetadata.totalTokenCount`）
  int get totalTokens => _totalTokens;

  @override
  Future<List<TranslationChunk>> translateBatch(String input) async {
    final GenerateContentResponse response;
    try {
      response = await client.models.generateContent(
        model: model,
        request: _createRequest(input),
      );
    } on GoogleAIException catch (e) {
      throw TranslationException('Gemini 请求失败\n$e\n', redact: [_apiKey]);
    }

    _totalTokens += response.usageMetadata?.totalTokenCount ?? 0;
    return _parser.parse(response.text ?? '');
  }
}
