import 'package:cfug_translator_bot/src/services/translation_service/placeholder_translator/translation_response_parser.dart';
import 'package:cfug_translator_bot/src/services/translation_service/translation_exception.dart';
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

    test('对象包数组 {"translations":[...]} 解析为译文块列表', () {
      final result = parser.parse(
        '{"translations":[{"id":"ID-1","indentCount":2,"text":"你好"}]}',
      );
      expect(result, hasLength(1));
      expect(result.first.id, 'ID-1');
      expect(result.first.indentCount, 2);
      expect(result.first.text, '你好');
    });

    test('对象缺少 translations 键时回退到首个数组值', () {
      final result = parser.parse(
        '{"result":[{"id":"ID-2","indentCount":0,"text":"世界"}]}',
      );
      expect(result, hasLength(1));
      expect(result.first.id, 'ID-2');
      expect(result.first.text, '世界');
    });

    test('对象中无任何数组值抛出 TranslationException', () {
      expect(
        () => parser.parse('{"message":"no array here"}'),
        throwsA(isA<TranslationException>()),
      );
    });

    test('非法 JSON 抛出 TranslationException', () {
      expect(
        () => parser.parse('not json'),
        throwsA(isA<TranslationException>()),
      );
    });
  });
}
