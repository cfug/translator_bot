import 'package:openai_dart/openai_dart.dart';

import '../../translation_service/model_session.dart';
import '../../translation_service/models/translation_chunk_model.dart';
import '../../translation_service/placeholder_translator/translation_response_parser.dart';
import '../../translation_service/translation_exception.dart';

typedef OpenAiRequestBuilder =
    ChatCompletionCreateRequest Function(String input);

class OpenAiModelSession implements ModelSession {
  /// OpenAI 协议的会话适配器
  ///
  /// - [client] 模型客户端（已内置模型配置）
  /// - [createRequest] 构造请求的函数，接收每批输入文本，返回完整的请求对象（包含模型配置等）
  OpenAiModelSession(
    this.client, {
    required OpenAiRequestBuilder createRequest,
    TranslationResponseParser parser = const TranslationResponseParser(),
  }) : _createRequest = createRequest,
       _parser = parser;

  final OpenAIClient client;
  final OpenAiRequestBuilder _createRequest;
  final TranslationResponseParser _parser;

  int _totalTokens = 0;

  /// 累计消耗的总 Token（来自各次响应的 `usage.total_tokens`）
  int get totalTokens => _totalTokens;

  @override
  Future<List<TranslationChunk>> translateBatch(String input) async {
    final ChatCompletion response;
    try {
      response = await client.chat.completions.create(_createRequest(input));
    } on OpenAIException catch (e) {
      throw TranslationException('OpenAI 请求失败\n$e\n');
    }

    _totalTokens += response.usage?.totalTokens ?? 0;
    return _parser.parse(response.text ?? '');
  }
}
