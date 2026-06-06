import 'package:cfug_translator_bot/src/services/translation_service/models/translation_chunk_model.dart';
import 'package:test/test.dart';

void main() {
  group('TranslationChunk.fromJson ::', () {
    test('合法 JSON 解析为强类型字段', () {
      final chunk = TranslationChunk.fromJson({
        'id': 'ID-1',
        'indentCount': 2,
        'text': '你好',
      });
      expect(chunk.id, 'ID-1');
      expect(chunk.indentCount, 2);
      expect(chunk.text, '你好');
    });

    test('indentCount 为数字字符串时容错解析为 int', () {
      expect(
        TranslationChunk.fromJson({
          'id': 'ID-1',
          'indentCount': '2',
          'text': '你好',
        }).indentCount,
        2,
      );
      // 浮点（字符串或数值）取整
      expect(
        TranslationChunk.fromJson({
          'id': 'ID-1',
          'indentCount': '2.0',
          'text': '你好',
        }).indentCount,
        2,
      );
      expect(
        TranslationChunk.fromJson({
          'id': 'ID-1',
          'indentCount': 2.0,
          'text': '你好',
        }).indentCount,
        2,
      );
      expect(
        TranslationChunk.fromJson({
          'id': 'ID-1',
          'indentCount': 2.5,
          'text': '你好',
        }).indentCount,
        2,
      );
    });

    test('indentCount 实在无法解析为数字时抛出 (fail-fast)', () {
      expect(
        () => TranslationChunk.fromJson({
          'id': 'ID-1',
          'indentCount': 'abc',
          'text': '你好',
        }),
        throwsA(isA<FormatException>()),
      );
    });

    test('indentCount 缺失时抛出 (fail-fast)', () {
      expect(
        () => TranslationChunk.fromJson({'id': 'ID-1', 'text': '你好'}),
        throwsA(isA<FormatException>()),
      );
    });

    test('id/text 类型错误或缺失时 fail-fast (TypeError)', () {
      expect(
        () => TranslationChunk.fromJson({'indentCount': 2, 'text': '你好'}),
        throwsA(isA<TypeError>()),
      );
    });
  });
}
