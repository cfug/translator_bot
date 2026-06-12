import 'dart:convert';

import 'package:cfug_translator_bot/src/services/model_service/gemini/gemini_model_session.dart';
import 'package:cfug_translator_bot/src/services/translation_service/translation_exception.dart';
import 'package:googleai_dart/googleai_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  group('GeminiModelSession :: 请求构造 ::', () {
    test(
      'POST 到 :generateContent，带 system instruction、user、responseSchema',
      () async {
        late http.Request captured;
        final client = MockClient((request) async {
          captured = request;
          final content = jsonEncode([
            {'id': 'ID-1', 'indentCount': 0, 'text': 'hi'},
          ]);
          return _ok(_genContent(content));
        });

        await _session(client).translateBatch('<INPUT>\nid: ID-1\n</INPUT>');

        expect(captured.method, 'POST');
        expect(captured.url.path, contains(':generateContent'));

        final body = jsonDecode(captured.body) as Map<String, dynamic>;

        /// 单轮无状态：contents 仅含本批 user 输入。
        final contents = body['contents'] as List;
        expect(contents, hasLength(1));
        expect(contents[0]['role'], 'user');
        expect(
          (contents[0]['parts'] as List)[0]['text'],
          '<INPUT>\nid: ID-1\n</INPUT>',
        );

        /// 系统指令与生成配置随请求下发。
        expect((body['systemInstruction']['parts'] as List)[0]['text'], 'SYS');
        final genConfig = body['generationConfig'] as Map<String, dynamic>;
        expect(genConfig['temperature'], 0.2);
        expect(genConfig['responseMimeType'], 'application/json');
        expect(genConfig['responseSchema'], isNotNull);
      },
    );
  });

  group('GeminiModelSession :: 响应处理 ::', () {
    test('解析译文数组，中文经 utf8 不乱码', () async {
      final client = MockClient((request) async {
        final content = jsonEncode([
          {'id': 'ID-1', 'indentCount': 2, 'text': '你好世界'},
        ]);
        return _ok(_genContent(content));
      });
      final chunks = await _session(client).translateBatch('x');
      expect(chunks, hasLength(1));
      expect(chunks.first.id, 'ID-1');
      expect(chunks.first.indentCount, 2);
      expect(chunks.first.text, '你好世界');
    });

    test('累加 usageMetadata.totalTokenCount', () async {
      var call = 0;
      final client = MockClient((request) async {
        call++;
        return _ok(_genContent('[]', totalTokenCount: 10 * call));
      });
      final session = _session(client);
      await session.translateBatch('a');
      await session.translateBatch('b');
      expect(session.totalTokens, 30); // 10 + 20
    });

    test('非 2xx 抛 TranslationException，且错误信息里的 key 被脱敏为 ***', () async {
      final client = MockClient((request) async {
        return http.Response.bytes(
          utf8.encode('{"error":{"message":"bad request, key: test-key"}}'),
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
            allOf(contains('***'), isNot(contains('test-key'))),
          ),
        ),
      );
    });
  });
}

/// 构造一条合法的 generateContent 响应（candidates[0].content.parts[0].text）。
String _genContent(String text, {int totalTokenCount = 0}) => jsonEncode({
  'candidates': [
    {
      'content': {
        'role': 'model',
        'parts': [
          {'text': text},
        ],
      },
    },
  ],
  'usageMetadata': {'totalTokenCount': totalTokenCount},
});

http.Response _ok(String body) => http.Response.bytes(
  utf8.encode(body),
  200,
  headers: {'content-type': 'application/json'},
);

GeminiModelSession _session(http.Client client) {
  final aiClient = GoogleAIClient.withApiKey('test-key', httpClient: client);
  return GeminiModelSession(
    aiClient,
    model: 'gemini-test',
    apiKey: 'test-key',
    createRequest: (input) => GenerateContentRequest(
      contents: [Content.text(input)],
      systemInstruction: const Content(parts: [TextPart('SYS')]),
      generationConfig: const GenerationConfig(
        temperature: 0.2,
        responseMimeType: 'application/json',
        responseSchema: {'type': 'ARRAY'},
      ),
    ),
  );
}
