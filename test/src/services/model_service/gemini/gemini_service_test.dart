import 'dart:convert';

import 'package:cfug_translator_bot/src/services/model_service/gemini/gemini_service.dart';
import 'package:cfug_translator_bot/src/services/model_service/model_service.dart'
    show ModelService;
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  group('GeminiService :: translatorChunk ::', () {
    test('实现 ModelService 接口', () {
      expect(_service(_echoClient()), isA<ModelService>());
    });

    test('跑完整流水线，返回译文 + token', () async {
      final result = await _service(
        _echoClient(totalTokens: 42),
      ).translatorChunk('# Hello\n\nWorld');

      expect(result.outputText, contains('# 译:Hello'));
      expect(result.outputText, contains('译:World'));
      expect(result.outputText, isNot(contains('<INPUT>')));
      expect(result.totalTokenCount, 42);
    });
  });
}

final _block = RegExp(r'<INPUT>\n(.*?)\n</INPUT>', dotAll: true);
final _id = RegExp(r'^id: (.*)$', multiLine: true);
final _indent = RegExp(r'^indentCount: (\d+)$', multiLine: true);
final _text = RegExp(r'^text: (.*)$', multiLine: true);

http.Response _ok(String body) => http.Response.bytes(
  utf8.encode(body),
  200,
  headers: {'content-type': 'application/json'},
);

/// echo Gemini 端点
///
/// - `generateContent`：解析请求里的 `<INPUT>` 批，
///   按 id/indentCount 原样回填、文本加 “译:” 前缀（绕开占位 ID 的 UUID 非确定性），以纯数组返回
/// - `countTokens`：回固定值
MockClient _echoClient({int totalTokens = 42}) {
  return MockClient((request) async {
    if (request.url.toString().contains('countTokens')) {
      return _ok(jsonEncode({'totalTokens': totalTokens}));
    }

    final body = jsonDecode(request.body) as Map<String, dynamic>;
    final contents = body['contents'] as List;
    final userText = ((contents.last as Map)['parts'] as List)
        .map((part) => (part as Map)['text'])
        .whereType<String>()
        .join();

    final translations = _block.allMatches(userText).map((match) {
      final inner = match.group(1)!;
      return {
        'id': _id.firstMatch(inner)!.group(1)!,
        'indentCount': int.parse(_indent.firstMatch(inner)!.group(1)!),
        'text': '译:${_text.firstMatch(inner)!.group(1)!}',
      };
    }).toList();

    return _ok(
      jsonEncode({
        'candidates': [
          {
            'content': {
              'role': 'model',
              'parts': [
                {'text': jsonEncode(translations)},
              ],
            },
          },
        ],
      }),
    );
  });
}

GeminiService _service(http.Client client) =>
    GeminiService(apiKey: 'test-key', httpClient: client);
