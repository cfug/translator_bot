import 'dart:convert';

import 'package:cfug_translator_bot/src/services/model_service/gemini/gemini_model_session.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  group('GeminiModelSession ::', () {
    test('发送 input 并把响应解析为译文块（中文经 utf8）', () async {
      late http.Request captured;
      final client = MockClient((request) async {
        captured = request;
        final content = jsonEncode([
          {'id': 'ID-1', 'indentCount': 2, 'text': '你好世界'},
        ]);
        return _ok(_genContent(content));
      });

      final chunks = await _session(
        client,
      ).translateBatch('<INPUT>marker</INPUT>');

      /// 请求确实把 input 发了出去（generateContent 端点）。
      expect(captured.method, 'POST');
      expect(captured.url.path, contains(':generateContent'));
      expect(captured.body, contains('marker'));

      /// 响应被解析为译文块。
      expect(chunks, hasLength(1));
      expect(chunks.first.id, 'ID-1');
      expect(chunks.first.indentCount, 2);
      expect(chunks.first.text, '你好世界');
    });
  });
}

/// 构造一条合法的 generateContent 响应（candidates[0].content.parts[0].text）。
String _genContent(String text) => jsonEncode({
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
});

http.Response _ok(String body) => http.Response.bytes(
  utf8.encode(body),
  200,
  headers: {'content-type': 'application/json'},
);

GeminiModelSession _session(http.Client client) {
  final model = GenerativeModel(
    model: 'gemini-test',
    apiKey: 'test-key',
    httpClient: client,
  );
  return GeminiModelSession(model.startChat());
}
