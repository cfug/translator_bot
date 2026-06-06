import 'dart:convert';

import 'package:cfug_translator_bot/src/services/model_service/openai/openai_service.dart';
import 'package:cfug_translator_bot/src/services/model_service/model_service.dart'
    show ModelService;
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  group('OpenAiService :: translatorChunk ::', () {
    test('实现 ModelService 接口', () {
      expect(_service(_echoClient()), isA<ModelService>());
    });

    test('跑完整流水线，返回译文 + token', () async {
      final result = await _service(
        _echoClient(),
      ).translatorChunk('# Hello\n\nWorld');
      expect(result.outputText, contains('# 译:Hello'));
      expect(result.outputText, contains('译:World'));
      expect(result.outputText, isNot(contains('<INPUT>')));
      expect(result.totalTokenCount, greaterThan(0));
    });
  });
}

final _block = RegExp(r'<INPUT>\n(.*?)\n</INPUT>', dotAll: true);
final _id = RegExp(r'^id: (.*)$', multiLine: true);
final _indent = RegExp(r'^indentCount: (\d+)$', multiLine: true);
final _text = RegExp(r'^text: (.*)$', multiLine: true);

/// echo OpenAI 端点
///
/// - `generateContent`：解析请求里的 `<INPUT>` 批，
///   按 id/indentCount 原样回填、文本加 “译:” 前缀（绕开占位 ID 的 UUID 非确定性），以纯数组返回
/// - `countTokens`：回固定值
MockClient _echoClient({int tokensPerCall = 7}) {
  return MockClient((request) async {
    final body = jsonDecode(request.body) as Map<String, dynamic>;
    final userContent = (body['messages'] as List)[1]['content'] as String;
    final translations = _block.allMatches(userContent).map((m) {
      final inner = m.group(1)!;
      return {
        'id': _id.firstMatch(inner)!.group(1)!,
        'indentCount': int.parse(_indent.firstMatch(inner)!.group(1)!),
        'text': '译:${_text.firstMatch(inner)!.group(1)!}',
      };
    }).toList();
    final responseBody = jsonEncode({
      'id': 'chatcmpl-test',
      'object': 'chat.completion',
      'created': 0,
      'model': 'gpt-x',
      'choices': [
        {
          'index': 0,
          'message': {
            'role': 'assistant',
            'content': jsonEncode({'translations': translations}),
          },
          'finish_reason': 'stop',
        },
      ],
      'usage': {
        'prompt_tokens': 1,
        'completion_tokens': 1,
        'total_tokens': tokensPerCall,
      },
    });
    return http.Response.bytes(
      utf8.encode(responseBody),
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  });
}

OpenAiService _service(http.Client client) => OpenAiService(
  apiKey: 'sk-test',
  baseUrl: 'https://api.example.com/v1',
  httpClient: client,
);
