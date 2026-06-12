import 'dart:convert';

import 'package:cfug_translator_bot/src/services/model_service/openai/openai_model_session.dart';
import 'package:cfug_translator_bot/src/services/translation_service/translation_exception.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('OpenAiModelSession :: 请求构造 ::', () {
    test(
      'POST 到 /chat/completions，带 Bearer、model、system+user、json_schema',
      () async {
        late http.Request captured;
        final client = MockClient((request) async {
          captured = request;
          final content = jsonEncode({
            'translations': [
              {'id': 'ID-1', 'indentCount': 0, 'text': 'hi'},
            ],
          });
          return _ok(_chatResponse(content));
        });

        await _session(client).translateBatch('<INPUT>\nid: ID-1\n</INPUT>');

        expect(captured.method, 'POST');
        expect(captured.url.path, endsWith('/chat/completions'));
        expect(captured.headers['authorization'], 'Bearer sk-test');

        final body = jsonDecode(captured.body) as Map<String, dynamic>;
        expect(body['model'], 'gpt-x');
        expect(body['temperature'], 0.2);

        final messages = body['messages'] as List;
        expect(messages, hasLength(2));
        expect(messages[0]['role'], 'system');
        expect(messages[0]['content'], 'SYS');
        expect(messages[1]['role'], 'user');
        expect(messages[1]['content'], '<INPUT>\nid: ID-1\n</INPUT>');

        /// 固定使用 json_schema 结构化输出。
        final rf = body['response_format'] as Map<String, dynamic>;
        expect(rf['type'], 'json_schema');
        expect((rf['json_schema'] as Map)['schema'], isNotNull);
      },
    );

    test('temperature 为 null 时不下发该参数', () async {
      late http.Request captured;
      final client = MockClient((request) async {
        captured = request;
        return _ok(_chatResponse('{"translations":[]}'));
      });
      await _session(client, temperature: null).translateBatch('x');
      final body = jsonDecode(captured.body) as Map<String, dynamic>;
      expect(body.containsKey('temperature'), isFalse);
    });
  });

  group('OpenAiModelSession :: 响应处理 ::', () {
    test('解析对象包数组，中文经 utf8 不乱码', () async {
      final client = MockClient((request) async {
        final content = jsonEncode({
          'translations': [
            {'id': 'ID-1', 'indentCount': 2, 'text': '你好世界'},
          ],
        });
        return _ok(_chatResponse(content));
      });
      final chunks = await _session(client).translateBatch('x');
      expect(chunks, hasLength(1));
      expect(chunks.first.id, 'ID-1');
      expect(chunks.first.indentCount, 2);
      expect(chunks.first.text, '你好世界');
    });

    test('累加 usage.total_tokens', () async {
      var call = 0;
      final client = MockClient((request) async {
        call++;
        return _ok(
          _chatResponse('{"translations":[]}', totalTokens: 10 * call),
        );
      });
      final session = _session(client);
      await session.translateBatch('a');
      await session.translateBatch('b');
      expect(session.totalTokens, 30); // 10 + 20
    });

    test('非 2xx 抛 TranslationException，且错误信息里的 key 被脱敏为 ***', () async {
      final client = MockClient((request) async {
        return http.Response.bytes(
          utf8.encode('{"error":{"message":"bad request key: sk-test"}}'),
          400,
          headers: {'content-type': 'application/json'},
        );
      });
      await expectLater(
        _session(client).translateBatch('x'),
        throwsA(
          isA<TranslationException>().having(
            (e) => e.message,
            'message',
            allOf(contains('***'), isNot(contains('sk-test'))),
          ),
        ),
      );
    });
  });
}

/// 构造一条合法的 chat/completions 响应
///
/// [content] 为模型 message.content（其本身是一段 JSON 字符串）。
String _chatResponse(String content, {int totalTokens = 0}) => jsonEncode({
  'id': 'chatcmpl-test',
  'object': 'chat.completion',
  'created': 0,
  'model': 'gpt-x',
  'choices': [
    {
      'index': 0,
      'message': {'role': 'assistant', 'content': content},
      'finish_reason': 'stop',
    },
  ],
  'usage': {
    'prompt_tokens': 1,
    'completion_tokens': 1,
    'total_tokens': totalTokens,
  },
});

http.Response _ok(String body) => http.Response.bytes(
  utf8.encode(body),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

OpenAiModelSession _session(http.Client client, {double? temperature = 0.2}) {
  final openAiClient = OpenAIClient.withApiKey(
    'sk-test',
    baseUrl: 'https://api.example.com/v1',
    httpClient: client,
  );
  return OpenAiModelSession(
    openAiClient,
    apiKey: 'sk-test',
    createRequest: (input) => ChatCompletionCreateRequest(
      model: 'gpt-x',
      temperature: temperature,
      messages: [ChatMessage.system('SYS'), ChatMessage.user(input)],
      responseFormat: ResponseFormat.jsonSchema(
        name: 'translation',
        schema: const {'type': 'object'},
        strict: true,
      ),
    ),
  );
}
