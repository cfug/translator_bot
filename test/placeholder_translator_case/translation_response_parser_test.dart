import 'package:cfug_translator_bot/src/services/translation_service/placeholder_translator/translation_response_parser.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:test/test.dart';

void main() {
  group('PlaceholderTranslator :: TranslationResponseParser ::', () {
    const parser = TranslationResponseParser();

    test('空白响应返回空列表', () {
      expect(parser.parse(''), isEmpty);
      expect(parser.parse('   \n  '), isEmpty);
    });

    test('合法 JSON 数组解析为译文块列表', () {
      final result = parser.parse(
        '[{"id":"ID-1","indentCount":2,"text":"你好"}]',
      );
      expect(result, hasLength(1));
      expect(result.first.id, 'ID-1');
      expect(result.first.indentCount, 2);
      expect(result.first.text, '你好');
    });

    test('非法 JSON 抛出 GenerativeAIException', () {
      expect(
        () => parser.parse('not json'),
        throwsA(isA<GenerativeAIException>()),
      );
    });
  });
}
